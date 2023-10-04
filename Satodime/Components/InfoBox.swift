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
    
    var body: some View {
        VStack {
            SatoText(text: text, style: .subtitle)
                .padding(12)
                .background(Constants.Colors.cellBackground)
                .cornerRadius(20)
        }
    }
}
