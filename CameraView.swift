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
    
    var body: some View {
        ZStack {
            CameraPreview(cameraViewModel: cameraViewModel)
                .ignoresSafeArea()
            
            if showHexColor {
                VStack {
                    Spacer()
                    Text(cameraViewModel.colorHex)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
                .padding()
                .onAppear {  // Update detectedHexColor when the Text appears
                    self.detectedHexColor = cameraViewModel.colorHex
                }
                .onChange(of: cameraViewModel.colorHex) { newValue in
                    self.detectedHexColor = newValue
                }
            }
        }
        .onAppear(perform: cameraViewModel.configureCaptureSession)
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
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No need to update the UIView as the AVCaptureVideoPreviewLayer will handle updates.
    }
}

