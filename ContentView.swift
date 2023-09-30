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
    
    var body: some View {
        ZStack {
            if showCamera {
                CameraView(expandCamera: $expandCamera, showHexColor: $showHexColor, detectedHexColor: $detectedHexColor)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .animation(Animation.easeInOut(duration: 4), value: expandCamera)
            }
            
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
                ColorChangingComponent(color: Color(hex: detectedHexColor), reverseRotation: $reverseRotation, scale: $shutterScale)  // Use shutterScale here
                    .frame(width: 100, height: 100)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            }
                       
                       // Hexagon
            if isButtonClicked {
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                        .frame(width: 400, height: 400)
                        .clipShape(Hexagon())
                        .scaleEffect(hexagonScale)  // Add this line to animate the transparent hexagon
                        
                    Hexagon()
                        .stroke(Color(hex: detectedHexColor), lineWidth: 5)
                        .frame(width: 400, height: 400)
                        .scaleEffect(hexagonScale)
                    
                    Text(detectedHexColor)
                        .foregroundColor(.white)
                        .bold()
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            }

                        // Capture Button
            if showCaptureButton && showCamera {
                            Button(action: {
                                isButtonClicked.toggle()
                                reverseRotation.toggle()
                                
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                                    hexagonScale = isButtonClicked ? 1 : 0.01
                                    shutterScale = isButtonClicked ? 0.1 : 1.0  // Toggle the shutter scale
                                }
                                
                                fireworkHapticEffect()
                                
                            }) {
                                Image(systemName: isButtonClicked ? "checkmark.circle" : "button.programmable")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(isButtonClicked ? Color.green : Color.white)
                            }
                            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
                        }
                    }
                    .onAppear() {
                        self.showGIF = true
                    }
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
            .onChange(of: reverseRotation) { _ in
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
