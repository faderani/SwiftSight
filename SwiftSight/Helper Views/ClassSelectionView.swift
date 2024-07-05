//
//  ClassSelectionView.swift
//  SwiftSight
//
//  Created by Soroush Shahi Vernousfaderani on 7/28/24.
//

import SwiftUI

struct ClassSelectionView: View {
    @Binding var selectedClasses: Set<String>
    let classNames: [String]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(classNames, id: \.self) { className in
                HStack {
                    Text(className)
                    Spacer()
                    if selectedClasses.contains(className) {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedClasses.contains(className) {
                        selectedClasses.remove(className)
                    } else {
                        selectedClasses.insert(className)
                    }
                }
            }
            .navigationTitle("Select Classes")
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
