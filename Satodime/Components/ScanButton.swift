//
//  ScanButton.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import SwiftUI

struct ScanButton: View {
    let action: () -> Void
    @State private var animate = false

    private let initialSize: CGFloat = 85
    private let animationCircleSize: CGFloat = 85 * 2.5

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: initialSize, height: initialSize)
                    .overlay(
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.35))
                                .scaleEffect(animate ? 1.2 : 1)
                                .opacity(animate ? 0 : 0.35)
                                .offset(x: 0, y: animate ? 0 : -(initialSize/2))
                                .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: false), value: animate)
                                .frame(width: animationCircleSize, height: animationCircleSize)
                        }
                    )
                    .shadow(radius: 10)
                
                Text("Click\n&\nScan")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            .contentShape(Rectangle())
            .frame(width: initialSize, height: initialSize)
        }
        .onAppear {
            animate = true
        }
    }
}
