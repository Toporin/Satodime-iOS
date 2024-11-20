//
//  InfoBox.swift
//  Satodime
//
//  Created by Lionel Delvaux on 04/10/2023.
//

import Foundation
import SwiftUI

struct InfoBox: View {
    let text: String
    var fullWidth: Bool
    var fixedHeight: CGFloat?
    
    init(text: String, fullWidth: Bool = false, fixedHeight: CGFloat? = nil) {
        self.text = text
        self.fullWidth = fullWidth
        self.fixedHeight = fixedHeight
    }
    
    var body: some View {
        VStack {
            SatoText(text: text, style: .graySubtitle)
                .padding(12)
                .background(Constants.Colors.cellBackground)
                .cornerRadius(20)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .frame(height: fixedHeight)
        }
        .padding(.horizontal, fullWidth ? 0 : nil)
    }
}
