//
//  ContentView.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/3/23.

import SwiftUI

struct ColorChangingComponent: View {
    var color: Color
    @State private var rotation: Double = 0
    
    var body: some View {
        Image("shutterwhite")
            .resizable()
            .scaledToFit()
            .colorMultiply(color)
            .rotationEffect(.degrees(rotation))
            .onAppear() {
                withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

struct CrosshairView: View {
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Rectangle().frame(width: 2, height: 50)
                Spacer()
            }
            HStack {
                Spacer()
                Rectangle().frame(width: 50, height: 2)
                Spacer()
            }
        }
        .foregroundColor(Color.black)
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
    @State var showPopup = false
    @State var showCaptureButton = false
    @State var isButtonClicked = false  // New state variable for button toggle

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
                ColorChangingComponent(color: Color(hex: detectedHexColor))
                    .frame(width: 100, height: 100)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            }
            
            if showCaptureButton && showCamera {
                Button(action: {
                    withAnimation {
                        self.isButtonClicked.toggle()
                    }
                }) {
                    if isButtonClicked {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.white)
                    } else {
                        Image(systemName: "button.programmable")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.white)
                    }
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 60)
            }
            
            if showPopup {
                VStack {
                    Text("Color Name")
                    Text(detectedHexColor)
                        .bold()
                }
                .frame(width: 200, height: 100)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
            }
        }
        .onAppear() {
            self.showGIF = true
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

