//
//  CameraView.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/3/23.
//
import SwiftUI
import AVFoundation
import UIKit

struct CameraView: View {
    @Binding var expandCamera: Bool
    @Binding var showHexColor: Bool
    @StateObject var cameraViewModel = CameraViewModel()
    @Binding var detectedHexColor: String  // The Binding variable
    @State private var zoomFactor: CGFloat = 1.0 // Initial zoom factor
    
    var body: some View {
        ZStack {
            CameraPreview(cameraViewModel: cameraViewModel)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                if cameraViewModel.minZoomFactor < cameraViewModel.maxZoomFactor {
                    Slider(value: $zoomFactor, in: cameraViewModel.minZoomFactor...cameraViewModel.maxZoomFactor, step: 0.1)
                        .padding()
                        .onChange(of: zoomFactor) {
                            cameraViewModel.set(zoom: zoomFactor)
                        }

                }
            }
        }
        .onAppear(perform: cameraViewModel.configureCaptureSession)
        .onAppear {  // Update detectedHexColor when the view appears
            self.detectedHexColor = cameraViewModel.colorHex
        }
        .onChange(of: cameraViewModel.colorHex) {
            self.detectedHexColor = cameraViewModel.colorHex
        }

    }
}



struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraViewModel: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraViewModel.captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Add pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch))
        view.addGestureRecognizer(pinchGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No need to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, cameraViewModel: cameraViewModel)
    }
    
    class Coordinator: NSObject {
        var view: CameraPreview
        var cameraViewModel: CameraViewModel
        
        init(_ view: CameraPreview, cameraViewModel: CameraViewModel) {
            self.view = view
            self.cameraViewModel = cameraViewModel
        }
        
        @objc func handlePinch(_ pinch: UIPinchGestureRecognizer) {
            switch pinch.state {
            case .began:
                pinch.scale = cameraViewModel.currentZoomFactor
            case .changed:
                let scale = pinch.scale
                cameraViewModel.set(zoom: scale)
            default:
                break
            }
        }
    }
}
