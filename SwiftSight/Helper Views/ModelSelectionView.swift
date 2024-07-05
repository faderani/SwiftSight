//
//  ModelSelectionView.swift
//  SwiftSight
//
//  Created by Soroush Shahi Vernousfaderani on 7/28/24.
//

import Foundation
import SwiftUI


struct ModelSelectionView: View {
    @Binding var selectedModel: Int
    @Environment(\.presentationMode) var presentationMode

    let models = ["YOLOv8n", "YOLOv8s", "YOLOv8m", "YOLOv8l", "YOLOv8x"]

    var body: some View {
        NavigationView {
            List(models.indices, id: \.self) { index in
                HStack {
                    Text(models[index])
                    Spacer()
                    if selectedModel == index {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedModel = index
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Select Model")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
