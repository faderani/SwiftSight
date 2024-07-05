//
//  OverlayView.swift
//  SwiftSight
//
//  Created by Soroush Shahi Vernousfaderani on 7/28/24.
//

import Foundation
import SwiftUI
import Vision

struct OverlayView: View {
    @ObservedObject var frameHandler: FrameHandler

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(sortedPredictions, id: \.self) { prediction in
                let bestClass = prediction.labels[0].identifier
                let confidence = prediction.labels[0].confidence
                Text("\(bestClass): \(confidence, specifier: "%.2f")")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.7))
                    .padding(4)
                    .cornerRadius(5)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // Helper computed property to sort predictions alphabetically
    private var sortedPredictions: [VNRecognizedObjectObservation] {
        frameHandler.predictions.sorted { (first, second) -> Bool in
            guard let firstClass = first.labels.first?.identifier,
                  let secondClass = second.labels.first?.identifier else {
                return false
            }
            return firstClass < secondClass
        }
    }
}
