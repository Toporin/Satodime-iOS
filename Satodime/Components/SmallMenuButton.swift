//
//  SmallMenuButton.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation
import SwiftUI

struct SmallMenuButton: View {
    let text: String
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 57)
        .background(backgroundColor)
        .cornerRadius(20)
    }
}
