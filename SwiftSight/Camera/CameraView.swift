//
//  VideoCapture.swift
//  SwiftSight
//
//  Created by Soroush Shahi Vernousfaderani on 7/22/24.
//

import SwiftUI
import AVFoundation
import Vision



// SwiftUI CameraView to integrate with VideoCapture.
struct CameraView: UIViewRepresentable {
    @ObservedObject var videoCapture: VideoCapture
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        videoCapture.setUp { success in
            if success, let previewLayer = videoCapture.previewLayer {
                previewLayer.frame = view.bounds
                view.layer.addSublayer(previewLayer)
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}


var mlModel = try! yolov8m(configuration: .init()).model

