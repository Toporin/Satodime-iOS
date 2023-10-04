//
//  SatoButton.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI

struct SatoButton: View {
    var text: String
    var style: ButtonStyle
    var horizontalPadding: CGFloat = Constants.Dimensions.defaultMargin
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, horizontalPadding)
                .frame(height: 40)
                .background(style.backgroundColor)
                .cornerRadius(20)
        }
    }
}

enum ButtonStyle {
    case confirm
    case inform

    var backgroundColor: Color {
        switch self {
        case .confirm:
            return Constants.Colors.confirmButtonBackground
        case .inform:
            return Constants.Colors.informButtonBackground
        }
    }

    var cornerRadius: CGFloat {
        return 20
    }
}
