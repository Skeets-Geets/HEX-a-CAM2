//
//  ContentView.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/3/23.


import SwiftUI

struct ColorChangingComponent: View {
    var color: Color
    @Binding var reverseRotation: Bool
    @Binding var scale: CGFloat
    @State private var rotation: Double = 0
    @State private var targetRotation: Double = 360

    var body: some View {
        Image("shutterwhitenew")
            .resizable()
            .scaledToFit()
            .colorMultiply(color)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .onAppear() {
                startRotation()
            }
            .onChange(of: reverseRotation){
                targetRotation = rotation + (reverseRotation ? -360 : 360)
                startRotation()
            }
    }

    private func startRotation() {
        withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
            rotation = targetRotation
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

func fireworkHapticEffect() {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.impactOccurred()
    DispatchQueue.global().async {
        for _ in 1...15 {
            usleep(10000)  // Reduced for faster haptics
            DispatchQueue.main.async {
                generator.impactOccurred()
            }
        }
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let sides = 6
        let angle = 2.0 * .pi / Double(sides)
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        
        for i in 0..<sides {
            let x = center.x + radius * cos(Double(i) * angle)
            let y = center.y + radius * sin(Double(i) * angle)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        
        return path
    }
}

struct ImageViewWrapper: UIViewRepresentable {
    var imageName: String
    var completion: ((Double) -> Void)?
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.loadGif(name: imageName) { duration in
            completion?(duration)
        }
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: ImageViewWrapper
        init(_ parent: ImageViewWrapper) {
            self.parent = parent
        }
        
        @objc func handleHapticFeedback() {
            let generator = UINotificationFeedbackGenerator()
            for _ in 1...6 {
                generator.notificationOccurred(.success)
                usleep(200000)
            }
        }
    }
}

struct ContentView: View {
    @State var expandCamera = false
    @State var showHexColor = false
    @State var showGIF = true
    @State var detectedHexColor: String = "#FFFFFF"
    @State var showCamera = false
    @State var showCaptureButton = false
    @State var isButtonClicked = false
    @State var reverseRotation: Bool = false
    @State var scale: CGFloat = 1.0  // Scale for the shutter component
    @State var hexagonScale: CGFloat = 0.01  // Initial small scale for the hexagon
    @State var showHexagon = false
    @State var shutterScale: CGFloat = 1.0
    @State var colorName: String = ""
    @State var button1Offset: CGFloat = 300
    @State var button2Offset: CGFloat = 300
    
    func animateButtonsIn() {
        // Your existing animateButtonsIn code
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                button1Offset = 0
            }
            
            
            // New function to animate buttons out
            func animateButtonsOut() {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                    button1Offset = 300
                    button2Offset = 300
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    button2Offset = 0
                }
            }
        }
    }
    
    func animateButtons() {
        if isButtonClicked {
            animateButtonsIn()
        } else {
            animateButtonsOut()
        }
    }
    
    var body: some View {
        ZStack {
#if !DEBUG
            if showCamera {
                CameraView(expandCamera: $expandCamera, showHexColor: $showHexColor, detectedHexColor: $detectedHexColor)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .animation(Animation.easeInOut(duration: 4), value: expandCamera)
            }
#endif
            if showGIF {
                ImageViewWrapper(imageName: "launch") { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation {
                            self.showGIF = false
                            self.showCamera = true
                            self.expandCamera = true
                        }
                        self.showHexColor = true
                        self.showCaptureButton = true
                    }
                }
            }
            
            if showCamera && !showGIF {
                ColorChangingComponent(color: Color(hex: detectedHexColor), reverseRotation: $reverseRotation, scale: $shutterScale)
                    .frame(width: 100, height: 100)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            }
            
            // Hexagon
            if isButtonClicked {
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                        .frame(width: 300, height: 300)
                        .clipShape(Hexagon())
                        .scaleEffect(hexagonScale)
                    
                    Hexagon()
                        .stroke(Color(hex: detectedHexColor), lineWidth: 5)
                        .frame(width: 300, height: 300)
                        .scaleEffect(hexagonScale)
                    
                    Text(detectedHexColor)
                        .foregroundColor(.white)
                        .bold()
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 50)
                .onAppear {
                    self.animateButtonsIn()
                }
                .onDisappear {
                    self.animateButtonsOut()
                }
                
                // Capture Button
                if showCaptureButton && showCamera {
                    Button(action: {
                        isButtonClicked.toggle()
                        reverseRotation.toggle()
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                            hexagonScale = isButtonClicked ? 1 : 0.01
                            shutterScale = isButtonClicked ? 0.1 : 1.0
                        }
                        
                        fireworkHapticEffect()
                        
                        fetchColorInfo(hex: detectedHexColor) { info in
                            if let info = info {
                                DispatchQueue.main.async {
                                    self.colorName = info.name["value"] ?? "Unknown"
                                }
                            }
                        }
                        
                        if isButtonClicked {
                            self.animateButtonsIn()
                        } else {
                            self.animateButtonsOut()
                        }
                        
                    }) {
                        Image(systemName: isButtonClicked ? "chevron.backward.circle.fill" : "button.programmable")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(isButtonClicked ? Color.green : Color.white)
                    }
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
                }
                
                VStack(spacing: 15) {
                    // Button 1
                    Button(action: {
                        // Your button 1 action
                    }) {
                        Text("Save Color")
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 5)
                            .font(.system(size: 18, weight: .thin, design: .default))
                    }
                    .background(VisualEffectView(effect: UIBlurEffect(style: .dark)))
                    .cornerRadius(20)
                    .offset(y: button1Offset)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1))
                    
                    // Button 2
                    Button(action: {
                        // Your button 2 action
                    }) {
                        Text("My Colors")
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .font(.system(size: 18, weight: .thin, design: .default))
                    }
                    .background(VisualEffectView(effect: UIBlurEffect(style: .dark)))
                    .cornerRadius(40)
                    .offset(y: button2Offset)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1))
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 250)
            }
        }
        .onAppear() {
            self.showGIF = true
        }
    }
    
    // Adding the missing animateButtonsOut function
    func animateButtonsOut() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
            button1Offset = 300
            button2Offset = 300
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ContentView()
                    .previewDevice("iPhone 12")
                ContentView()
                    .previewDevice("iPhone SE (2nd generation)")
            }
        }
    }
}



