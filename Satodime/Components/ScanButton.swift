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
    @State private var scale = 1.0
    
    private let initialSize: CGFloat = 85 //64
    private let maxExpansion: CGFloat = 85 * 2.5 //64 * 2.5
    let delay: Double = 0.5
    let maxScale = 1.5

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(animate ? LinearGradient(colors: [.blue.opacity(0.5), .blue.opacity(0.05)], startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [.gray.opacity(0.8), .gray.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                    .scaleEffect(scale)
                    .opacity(maxScale - scale)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: false).delay(delay)) {
                            scale = maxScale
                        }
                    }
                
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: initialSize, height: initialSize)
                    .shadow(radius: 10)
                
                Text("Click\n&\nScan") // Text("Scan")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            .contentShape(Rectangle())
            .frame(width: maxExpansion, height: maxExpansion)
            .onAppear {
                self.animate = true
            }
        }
    }
}
