//
//  ContentView.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/3/23.


import SwiftUI
import CoreData
import SpriteKit
 

func fireworkHapticEffect() {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.impactOccurred()
    DispatchQueue.global().async {
        for _ in 1...15 {
            usleep(15000)  //adjusted sleep duration for better haptic effect
            DispatchQueue.main.async {
                generator.impactOccurred()
            }
        }
    }
}


struct MorphingShape: Shape {
    var animationProgress: CGFloat

    func path(in rect: CGRect) -> Path {
        if animationProgress <= 0.5 {
            return hexagonPath(in: rect, progress: animationProgress * 2)
        } else {
            return roundedRectPath(in: rect, progress: (animationProgress - 0.5) * 2)
        }
    }


    private func hexagonPath(in rect: CGRect, progress: CGFloat) -> Path {
        
        let sides = 6
        let angle = 2.0 * .pi / Double(sides)
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        
        for i in 0..<sides {
            let x = center.x + radius * CGFloat(cos(Double(i) * angle))
            let y = center.y + radius * CGFloat(sin(Double(i) * angle))
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }

    private func roundedRectPath(in rect: CGRect, progress: CGFloat) -> Path {
        let cornerRadius = interpolate(from: 0, to: rect.width / 4, progress: progress)
        return RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
    }

    private func interpolate(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        return from + (to - from) * progress
    }
}

struct ImageViewWrapper: UIViewRepresentable {
    var imageName: String
    var completion: ((Double) -> Void)?
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
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
    var animationProgress: CGFloat
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                .frame(width: 300, height: 300)
                .clipShape(MorphingShape(animationProgress: animationProgress))
            
            MorphingShape(animationProgress: animationProgress)
                .stroke(color, lineWidth: strokeWidth)
        }
        .frame(width: 300, height: 300)
        .scaleEffect(hexagonScale)
        .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1), value: hexagonScale)
    }
}

// Struct for GifView
struct GifView: UIViewRepresentable {
    var gifName: String

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let imageView = UIImageView()
        imageView.loadGif(name: gifName)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}




struct ContentView: View {
    let shutterFrames: [Image] = (1...21).map { Image("rainShut-\($0)") }
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
    @State var capturedColor: Color = Color.white
    @State var capturedHexCode: String = "#FFFFFF"  // Default value
    @Environment(\.managedObjectContext) private var managedObjectContext
    @State private var animationProgress: CGFloat = 0
    @State private var hideSaveButton: Bool = false
    @State private var currentFrameIndex = 0
    @ObservedObject var cameraViewModel: CameraViewModel
    @State var rotationAngle: Double = 0
    @State var shouldShowRainShut = false
    @State private var showMyColorsMenu = false
    @State private var isMenuVisible: Bool = false
    @State private var isMyColorsMenuOpen = false
    @State var menuScale: CGFloat = 0.01


    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    let myColorsFrames: [Image] = (1...19).map { Image("MYcolors-\($0)") }

    var body: some View {
            GeometryReader { geometry in
                ZStack {
                    cameraSection(geometry: geometry)
                    gifSection(geometry: geometry)
                    buttonSection(geometry: geometry, shutterFrames: shutterFrames, rotationAngle: $rotationAngle)
                    hexagonSection(geometry: geometry)
                    captureButtonSection(geometry: geometry)

                    // Display ColorChangingComponent if shouldShowRainShut is true
                    if shouldShowRainShut {
                        ColorChangingComponent(color: Color.white, scale: $shutterScale)
                            .zIndex(0)
                    }
                }
            }
            .onAppear {
                self.showGIF = true
                self.shutterScale = 0.5
            }
        }
    @ViewBuilder
        private func gifSection(geometry: GeometryProxy) -> some View {
            if showGIF {
                ImageViewWrapper(imageName: "launch") { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation {
                            self.showGIF = false
                            self.showCamera = true
                            self.expandCamera = true
                        }
                        self.showHexColor = true
                        self.showCaptureButton = true
                        self.shouldShowRainShut = true
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    @ViewBuilder
    private func cameraSection(geometry: GeometryProxy) -> some View {
        if showCamera {
            #if !DEBUG
            CameraView(expandCamera: $expandCamera, showHexColor: $showHexColor, detectedHexColor: $detectedHexColor)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .animation(Animation.easeInOut(duration: 4), value: expandCamera)
            #endif

        }
    }


    //BUTTON 1 MY COLORS
    @ViewBuilder
    private func buttonSection(geometry: GeometryProxy, shutterFrames: [Image], rotationAngle: Binding<Double>) -> some View {
        if isButtonClicked {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.2, blendDuration: 0.5)) {
                    animationProgress = 0
                    hideSaveButton.toggle()
                    if !hideSaveButton {
                        captureButtonScale = 1.0
                    }
                    isMenuVisible.toggle()
                    hexagonScale = isMenuVisible ? 0.1 : 1.0
                }
            }) {
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                        .frame(width: 145, height: 30)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: capturedHexCode), lineWidth: 2)
                        )
                    myColorsFrames[currentFrameIndex]
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 15)
                        .onReceive(timer) { _ in
                            currentFrameIndex = (currentFrameIndex + 1) % myColorsFrames.count
                        }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .offset(y: self.buttonOffset - 30)
            .opacity(buttonOpacity)
            .animation(Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.5), value: buttonOffset)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + buttonOffset + 70)
            .onAppear {
                withAnimation(Animation.linear(duration: 5).repeatForever(autoreverses: false)) {
                    rotationAngle.wrappedValue = 360.0
                }
            }

            Button(action: {
                print("Save Color button clicked")
            }) {
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                        .frame(width: 120, height: 25)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: capturedHexCode), lineWidth: 2)
                        )
                    Text("Save Color")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .offset(y: self.saveButtonOffset - 30)
            .opacity(saveButtonOpacity)
            .animation(Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.5), value: saveButtonOffset)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + saveButtonOffset - 10)

            if isMenuVisible {
                MyColorsMenu(isMenuVisible: $isMenuVisible, hexagonScale: $hexagonScale, gifFrames: myColorsFrames)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
                    .zIndex(2)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isMenuVisible = false
                            hexagonScale = 1.0
                        }
                    }
            }
        }
    }


    // Hexagon
    @ViewBuilder
    private func hexagonSection(geometry: GeometryProxy) -> some View {
        if isButtonClicked {
            AnimatedHexagon(
                color: isButtonClicked ? Color(hex: capturedHexCode) : Color(hex: detectedHexColor),
                strokeWidth: strokeWidth,
                hexagonScale: hexagonScale,
                animationProgress: animationProgress
            )
            .scaleEffect(hexagonScale)
            .animation(.spring(), value: hexagonScale)
            .zIndex(1)

            if !isMenuVisible {
                // For displaying the hex code value:
                ColorDisplayView(networkManager: networkManager, detectedHexColor: capturedHexCode, strokeColor: Color(hex: capturedHexCode))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }


    // Capture Button
    @ViewBuilder
    private func captureButtonSection(geometry: GeometryProxy) -> some View {
        if showCaptureButton && showCamera {
            Button(action: {
                isButtonClicked.toggle()
                cameraViewModel.stopCameraFeed()  // Stopping the camera feed on the instance
                reverseRotation.toggle()
                capturedHexCode = detectedHexColor  //capturedHexCode here

                withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                    hexagonScale = isButtonClicked ? 1 : 0.01
                    strokeWidth = isButtonClicked ? 10 : 2
                    shutterScale = isButtonClicked ? 0.1 : 1.0
                }

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
                    .scaleEffect(captureButtonScale)
                    .animation(Animation.spring(response: 0.3, dampingFraction: 0.6).delay(0.1), value: captureButtonScale)
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height - geometry.size.height * 0.05)
        }
    }


    private func animateButtonToFinalPosition() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.buttonOffset = 100
            self.buttonOpacity = 1
        }
    }
}

struct ColorChangingComponent: View {
    var color: Color
    @Binding var scale: CGFloat
    @State private var currentFrameIndex = 0
    @State private var rotationAngle: Double = 0  // managing rotation
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    let shutterFrames: [Image] = (1...20).map { Image("rainShut-\($0)") }

    var body: some View {
        shutterFrames[currentFrameIndex]
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .onReceive(timer) { _ in
                print("Timer fired, updating frame index.")
                if shutterFrames.count > 0 {  // Checking that the array is not empty
                    currentFrameIndex = (currentFrameIndex + 1) % shutterFrames.count
                }
            }

            .rotationEffect(.degrees(rotationAngle))
            .animation(Animation.linear(duration: 5).repeatForever(autoreverses: false), value: rotationAngle)
            .scaleEffect(scale)
            .animation(Animation.spring(response: 0.3, dampingFraction: 0.6).delay(0.1), value: scale)
            .onAppear {
                withAnimation(Animation.linear(duration: 5).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
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
        let dummyCameraViewModel = CameraViewModel()

        Group {
            ContentView(cameraViewModel: dummyCameraViewModel)
                .previewDevice("iPhone 12")
            ContentView(cameraViewModel: dummyCameraViewModel)
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}

