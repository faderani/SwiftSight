//
//  ContentView.swift
//  SwiftSight
//
//  Created by Soroush Shahi Vernousfaderani on 7/22/24.
//

import SwiftUI
import AVFoundation
import Vision



struct ContentView: View {
    @StateObject private var videoCapture = VideoCapture()
    @StateObject private var frameHandler = FrameHandler()
    @State private var showClassSelection = false
    @State private var showModelSelection = false

    let classNames = [
        "airplane", "apple", "backpack", "banana", "baseball bat", "baseball glove", "bear", "bed",
        "bench", "bicycle", "bird", "boat", "bottle", "bowl", "broccoli", "bus", "cake", "car", "carrot", "cat",
        "cell phone", "chair", "clock", "couch", "cow", "cup", "dining table", "dog", "donut", "elephant",
        "fire hydrant", "fork", "frisbee", "giraffe", "hair drier", "handbag", "horse", "hot dog", "keyboard",
        "kite", "knife", "laptop", "microwave", "motorbike", "mouse", "orange", "oven", "parking meter", "person",
        "potted plant", "refrigerator", "remote", "sandwich", "scissors", "sheep", "sink", "skateboard", "skis",
        "snowboard", "sports ball", "stop sign", "suitcase", "surfboard", "teddy bear", "tennis racket", "tie",
        "toaster", "toilet", "toothbrush", "traffic light", "train", "truck", "tv", "umbrella", "vase", "wine glass", "zebra"
    ]

    var body: some View {
        NavigationView {
            ZStack {
                CameraView(videoCapture: videoCapture)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        videoCapture.delegate = frameHandler
                    }
                OverlayView(frameHandler: frameHandler)
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            showClassSelection.toggle()
                        }) {
                            Text("Select Classes")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                        }
                        Button(action: {
                            showModelSelection.toggle()
                        }) {
                            Text("Select Model")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showClassSelection) {
                ClassSelectionView(selectedClasses: $frameHandler.selectedClasses, classNames: classNames)
            }
            .sheet(isPresented: $showModelSelection) {
                ModelSelectionView(selectedModel: $frameHandler.selectedModel)
            }
            .navigationTitle("Camera Live View")
            .navigationBarHidden(true)
        }
    }
}
