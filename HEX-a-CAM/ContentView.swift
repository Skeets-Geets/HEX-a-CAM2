
//
//  ContentView.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/3/23.


import SwiftUI

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
        imageView.contentMode = .scaleAspectFit  // Added this line
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

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

struct AnimatedHexagon: View {
    var color: Color
    var strokeWidth: CGFloat
    var hexagonScale: CGFloat
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                .frame(width: 300, height: 300)  // static size specified here
                .clipShape(Hexagon())
            
            Hexagon()
                .stroke(color, lineWidth: strokeWidth)
        }
        .frame(width: 300, height: 300)  // static size specified here
        .scaleEffect(hexagonScale)
        .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1), value: hexagonScale)  // Applying animation here
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
    @State var strokeWidth: CGFloat = 2
    @State private var buttonOffset: CGFloat = 0  // Initial offset to hide the button behind the hexagon
    @State private var showButton = false
    @State private var animateButton: Bool = false
    @State private var buttonOpacity: Double = 0
    @State var saveButtonOffset: CGFloat = 0  // Initial offset for Save Color button
    @State var saveButtonOpacity: Double = 0
    @State private var captureButtonScale: CGFloat = 1.0
    @StateObject var networkManager = NetworkManager()
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack {
                #if !DEBUG
                if showCamera {
                    CameraView(expandCamera: $expandCamera, showHexColor: $showHexColor, detectedHexColor: $detectedHexColor)
                        .frame(width: geometry.size.width, height: geometry.size.height)
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
                    .frame(width: geometry.size.width, height: geometry.size.height)  // Specify the frame size directly here
                }

                
                if showCamera && !showGIF {
                    ColorChangingComponent(
                        color: Color(hex: detectedHexColor),
                        reverseRotation: $reverseRotation,
                        scale: $shutterScale
                    )
                    .frame(width: 100, height: 100)
                }
                
                //BUTTON 1 MY COLORS
                if isButtonClicked {
                    Button(action: {
                        // your button action here
                    }) {
                        ZStack {
                            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                                .frame(width: 145, height: 30)
                                .cornerRadius(30)
                            Text("My Colors")
                                .foregroundColor(.primary)
                                .bold()
                                .kerning(2.0)
                        }
                    }
                    .offset(y: self.buttonOffset - 30)
                    .opacity(buttonOpacity)
                    .animation(Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.5), value: buttonOffset)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + buttonOffset)
                    .onAppear {
                        animateButtonToFinalPosition()
                    }
                }
                //BUTTON 2 SAVE COLOR
                if isButtonClicked {
                    Button(action: {
                        // Define your action for Save Color button
                    }) {
                        ZStack {
                            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                                .frame(width: 120, height: 30)
                                .cornerRadius(30)
                                .opacity(self.saveButtonOpacity)
                            
                            Text("Save Color")
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                    .offset(y: self.saveButtonOffset + geometry.size.height * 0.15 - 10)
                    .animation(Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: saveButtonOffset)
                    .animation(Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: saveButtonOpacity)
                }
                
                
                
                // Hexagon
                if isButtonClicked {
                    AnimatedHexagon(
                        color: Color(hex: detectedHexColor),
                        strokeWidth: strokeWidth,
                        hexagonScale: hexagonScale
                    )
                    ColorDisplayView(networkManager: networkManager, detectedHexColor: detectedHexColor)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                }
                
                
                // Capture Button
                if showCaptureButton && showCamera {
                    Button(action: {
                        isButtonClicked.toggle()
                        reverseRotation.toggle()
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                            hexagonScale = isButtonClicked ? 1 : 0.01
                            strokeWidth = isButtonClicked ? 10 : 2  // Toggle the stroke width
                            shutterScale = isButtonClicked ? 0.1 : 1.0  // Toggle the shutter scale
                        }
                        
                        // New code to animate button
                        withAnimation(Animation.spring(response: 0.3, dampingFraction: 15, blendDuration: 10)) {
                            self.buttonOffset = isButtonClicked ? 60 : 0  // Toggle position
                            self.buttonOpacity = isButtonClicked ? 1 : 0  // Toggle opacity
                            self.saveButtonOffset = isButtonClicked ? 120 : 0  // Toggle position for Save Color button
                            self.saveButtonOpacity = isButtonClicked ? 1 : 0  // Toggle opacity for Save Color button
                            self.captureButtonScale = isButtonClicked ? 1.2 : 1.0  // Toggle scale for Capture Button
                        }
                        
                        fireworkHapticEffect()
                        
                    }) {
                        Image(systemName: isButtonClicked ? "chevron.backward.circle.fill" : "button.programmable")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(isButtonClicked ? Color.green : Color.white)
                            .scaleEffect(captureButtonScale)  // Apply the scale effect here
                            .animation(Animation.spring(response: 0.3, dampingFraction: 0.6).delay(0.1), value: captureButtonScale)  // Spring animation for scale effect
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height - geometry.size.height * 0.05)
  // Adjusted the y position
                }
            }
            
            .onAppear() {
                self.showGIF = true
            }
        }
    }
    private func animateButtonToFinalPosition() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.buttonOffset = 100
            self.buttonOpacity = 1
        }
    }

    
    
    
    
    // Helper function to animate the button back to its start position
    private func animateButtonToStartPosition() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.buttonOffset = 0
            self.buttonOpacity = 0
        }
    }
    struct ColorChangingComponent: View {
        var color: Color
        @Binding var reverseRotation: Bool
        @Binding var scale: CGFloat
        @State private var rotation: Double = 0
        @State private var targetRotation: Double = 360
        
        var body: some View {
            Image("shutterwhite")
                .resizable()
                .scaledToFit()
                .colorMultiply(color)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .onAppear() {
                    startRotation()
                }
                .onChange(of: reverseRotation) {
                    targetRotation = rotation + (reverseRotation ? -360 : 360)
                    startRotation()
                }
        }
        
        private func startRotation() {
            withAnimation(Animation.linear(duration: 5).repeatForever(autoreverses: false)) {  // Reduced duration to 5 seconds
                rotation = targetRotation
            }
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
