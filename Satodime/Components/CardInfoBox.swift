//
//  CardInfoBox.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import SwiftUI

struct CardInfoBox: View {
    let text: String
    let backgroundColor: Color
    var width: CGFloat?
    var action: (() -> Void)?
    
    var body: some View {
        SatoText(text: text, style: .subtitle)
            .padding()
            .frame(width: width, height: 55)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .background(backgroundColor)
            .cornerRadius(20)
            .lineLimit(1)
            .foregroundColor(.white)
            .onTapGesture {
                action?()
            }
    }
}

