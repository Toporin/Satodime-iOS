//
//  SatoButton.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI

enum ButtonStyle {
    case confirm
    case inform
    case danger

    var backgroundColor: Color {
        switch self {
        case .confirm:
            return Constants.Colors.confirmButtonBackground
        case .inform:
            return Constants.Colors.informButtonBackground
        case .danger:
            return Constants.Colors.ledRed
        }
    }

    var cornerRadius: CGFloat {
        return 20
    }
}

struct SatoButton: View {
    let staticWidth: CGFloat
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
                .frame(width: staticWidth, height: 40)
                .background(style.backgroundColor)
                .cornerRadius(20)
        }
    }
}
