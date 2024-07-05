//
//  FrameHandler.swift
//  SwiftSight
//
//  Created by Soroush Shahi Vernousfaderani on 7/28/24.
//

import Foundation
import Vision
import UIKit


class FrameHandler: VideoCaptureDelegate, ObservableObject {
    @Published var predictions: [VNRecognizedObjectObservation] = []
    @Published var selectedClasses: Set<String> = []
    @Published var selectedModel: Int = 2 {
        didSet {
            updateModel()
        }
    }

    var currentBuffer: CVPixelBuffer?
    var detector: VNCoreMLModel!

    init() {
        updateModel()
    }

    func updateModel() {
        switch selectedModel {
        case 0:
            detector = try! VNCoreMLModel(for: yolov8n(configuration: .init()).model)
        case 1:
            detector = try! VNCoreMLModel(for: yolov8s(configuration: .init()).model)
        case 2:
            detector = try! VNCoreMLModel(for: yolov8m(configuration: .init()).model)
        case 3:
            detector = try! VNCoreMLModel(for: yolov8l(configuration: .init()).model)
        case 4:
            detector = try! VNCoreMLModel(for: yolov8x(configuration: .init()).model)
        default:
            detector = try! VNCoreMLModel(for: yolov8m(configuration: .init()).model)
        }

        visionRequest = VNCoreMLRequest(model: detector, completionHandler: {
            [weak self] request, error in
            self?.processObservations(for: request, error: error)
        })
        visionRequest.imageCropAndScaleOption = .scaleFill
    }

    lazy var visionRequest: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: detector, completionHandler: {
            [weak self] request, error in
            self?.processObservations(for: request, error: error)
        })
        request.imageCropAndScaleOption = .scaleFill
        return request
    }()

    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CMSampleBuffer) {
        predict(sampleBuffer: didCaptureVideoFrame)
    }

    func predict(sampleBuffer: CMSampleBuffer) {
        if currentBuffer == nil, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            currentBuffer = pixelBuffer

            let imageOrientation: CGImagePropertyOrientation
            switch UIDevice.current.orientation {
            case .portrait:
                imageOrientation = .up
            case .portraitUpsideDown:
                imageOrientation = .down
            case .landscapeLeft:
                imageOrientation = .left
            case .landscapeRight:
                imageOrientation = .right
            case .unknown:
                print("The device orientation is unknown, the predictions may be affected")
                fallthrough
            default:
                imageOrientation = .up
            }

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: imageOrientation, options: [:])
            if UIDevice.current.orientation != .faceUp {
                do {
                    try handler.perform([visionRequest])
                } catch {
                    print(error)
                }
            }

            currentBuffer = nil
        }
    }

    func processObservations(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let results = request.results as? [VNRecognizedObjectObservation] {
                self.predictions = results.filter { observation in
                    guard let bestClass = observation.labels.first?.identifier else {
                        return false
                    }
                    return self.selectedClasses.contains(bestClass)
                }
            } else {
                self.predictions = []
            }
        }
    }
}

