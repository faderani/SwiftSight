//
//  VideoCapture.swift
//  SwiftSight
//
//  Created by Soroush Shahi Vernousfaderani on 7/28/24.
//

import Foundation
import AVFoundation

// Defines the protocol for handling video frame capture events.
public protocol VideoCaptureDelegate: AnyObject {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CMSampleBuffer)
}

// Identifies the best available camera device based on user preferences and device capabilities.
func bestCaptureDevice() -> AVCaptureDevice {
    if UserDefaults.standard.bool(forKey: "use_telephoto"), let device = AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back) {
        return device
    } else if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
        return device
    } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
        return device
    } else {
        fatalError("Expected back camera device is not available.")
    }
}


// Custom VideoCapture class handling camera setup and video frames.
public class VideoCapture: NSObject, ObservableObject {
    public var previewLayer: AVCaptureVideoPreviewLayer?
    public weak var delegate: VideoCaptureDelegate?
    
    let captureDevice = bestCaptureDevice()
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    let cameraOutput = AVCapturePhotoOutput()
    let queue = DispatchQueue(label: "camera-queue")

    // Configures the camera and capture session with optional session presets.
    public func setUp(sessionPreset: AVCaptureSession.Preset = .hd1280x720, completion: @escaping (Bool) -> Void) {
        queue.async {
            let success = self.setUpCamera(sessionPreset: sessionPreset)
            DispatchQueue.main.async {
                completion(success)
                if success {
                    self.start() // Start the session only after configuration is done.
                }
            }
        }
    }

    // Internal method to configure camera inputs, outputs, and session properties.
    private func setUpCamera(sessionPreset: AVCaptureSession.Preset) -> Bool {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = sessionPreset
        
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return false
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        self.previewLayer = previewLayer
        
        let settings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
        ]
        
        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        if captureSession.canAddOutput(cameraOutput) {
            captureSession.addOutput(cameraOutput)
        }
        
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
        
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.focusMode = .continuousAutoFocus
            captureDevice.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            captureDevice.exposureMode = .continuousAutoExposure
            captureDevice.unlockForConfiguration()
        } catch {
            print("Unable to configure the capture device.")
            return false
        }
        
        captureSession.commitConfiguration()
        return true
    }

    // Starts the video capture session.
    public func start() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }

    // Stops the video capture session.
    public func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

// Extension to handle AVCaptureVideoDataOutputSampleBufferDelegate events.
extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.videoCapture(self, didCaptureVideoFrame: sampleBuffer)
    }

    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Optionally handle dropped frames, e.g., due to full buffer.
    }
}

