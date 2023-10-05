//
//  CameraView.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/3/23.
//
//
import SwiftUI
import AVFoundation
import UIKit

struct CameraView: View {
    @Binding var expandCamera: Bool
    @Binding var showHexColor: Bool
    @StateObject var el = CameraViewModel()
    @Binding var detectedHexColor: String  // The Binding variable
    @State private var zoomFactor: CGFloat = 1.0 // Initial zoom factor
    
    var body: some View {
        ZStack {
            CameraPreview(el: el)
                .ignoresSafeArea()
            
            VStack {
                Spacer()

            }
        }
        .onAppear(perform: el.configureCaptureSession)
        .onChange(of: el.colorHex) { newValue in
            self.detectedHexColor = el.colorHex
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var el: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: el.captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        //pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch))
        view.addGestureRecognizer(pinchGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, el: el)
    }
    
    class Coordinator: NSObject {
        var view: CameraPreview
        var el: CameraViewModel
        
        init(_ view: CameraPreview, el: CameraViewModel) {
            self.view = view
            self.el = el
        }
        
        @objc func handlePinch(_ pinch: UIPinchGestureRecognizer) {
            switch pinch.state {
            case .began:
                pinch.scale = CGFloat(el.currentZoomFactor)  // Convert to CGFloat
            default:
                el.set(zoom: pinch.scale)  // Convert to Float
            }
        }

    }
}

