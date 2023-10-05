//
//  CameraViewModel.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/3/23.
//
import Foundation
import AVFoundation
import UIKit
import CoreGraphics

class CameraViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    var captureSession: AVCaptureSession = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput!
    
    @Published var colorHex: String = "#FFFFFF"
    @Published var currentZoomFactor: CGFloat = 1.0
    var minZoomFactor: CGFloat = 1.0
    var maxZoomFactor: CGFloat = 4.0
    
    var lastNColors: [UIColor] = []  // To keep track of the last 'n' colors
    let n = 10  // Number of frames to average over
    
    func stopCameraFeed() {
        let captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
    }
        func resumeCameraFeed() {
            let captureSession = AVCaptureSession()
           captureSession.commitConfiguration()
        }
    func configureCaptureSession() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            fatalError("No back camera available.")
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(input)
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(output)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        } catch {
            print("Error configuring capture session: \(error)")
        }
    }
    
    func startSession() {
        captureSession.startRunning()
    }

    func endSession() {
        captureSession.stopRunning()
    }
    
    func set(zoom: CGFloat) {
        let device = videoDeviceInput.device   
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = zoom
            device.unlockForConfiguration()
        } catch {
            print("Error setting zoom: \(error)")
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
            let uiImage = UIImage(cgImage: cgImage)
            
            let centerX = uiImage.size.width / 2
            let centerY = uiImage.size.height / 2
            let boxSize: CGFloat = 120
            
            var totalRed: CGFloat = 0
            var totalGreen: CGFloat = 0
            var totalBlue: CGFloat = 0
            
            for x in Int(centerX - boxSize / 2)...Int(centerX + boxSize / 2) {
                for y in Int(centerY - boxSize / 2)...Int(centerY + boxSize / 2) {
                    let color = uiImage.getPixelColor(at: CGPoint(x: x, y: y))
                    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                    color.getRed(&r, green: &g, blue: &b, alpha: &a)
                    totalRed += r
                    totalGreen += g
                    totalBlue += b
                }
            }

        let pixelCount = boxSize * boxSize
                let averageRed = totalRed / pixelCount
                let averageGreen = totalGreen / pixelCount
                let averageBlue = totalBlue / pixelCount
                
                let averageColor = UIColor(red: averageRed, green: averageGreen, blue: averageBlue, alpha: 1)
                
                DispatchQueue.main.async {
                    self.colorHex = averageColor.toHexString()
                }
            }
        }

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let red = Int(r * 255)
        let green = Int(g * 255)
        let blue = Int(b * 255)
        
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

extension UIImage {
    func getPixelColor(at point: CGPoint) -> UIColor {
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(point.y)) + Int(point.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)

    }
}

