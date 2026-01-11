import SwiftUI
import UIKit

struct NumericKeypadView: View {
    @Binding var input: String
    
    private let buttons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "delete.left.fill"]
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 25) {
                    ForEach(row, id: \.self) { label in
                        KeypadButton(label: label, action: handleInput)
                    }
                }
            }
        }
    }
    
    private func handleInput(label: String) {
        // Remove haptics to avoid simulator/mac warnings about missing patterns.
        if label == "delete.left.fill" {
            if !input.isEmpty { input.removeLast() }
        } else if input.count < 6 && !label.isEmpty {
            input += label
        }
    }
}

struct KeypadButton: View {
    let label: String
    let action: (String) -> Void
    
    var body: some View {
        Button(action: { action(label) }) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 70, height: 70)
                
                if label.contains(".") {
                    Image(systemName: label)
                        .font(.title2)
                        .foregroundColor(.primary)
                } else if label.isEmpty {
                    Text("")
                } else {
                    Text(label)
                        .font(.largeTitle)
                        .fontWeight(.light)
                        .foregroundColor(.primary)
                }
            }
        }
        .disabled(label.isEmpty)
    }
}
//
//  NumericKeypadView.swift
//  Tunga
//
//  Created by Amani on 12/12/25.
//

