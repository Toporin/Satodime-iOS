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
    var text: String
    var style: ButtonStyle
    var horizontalPadding: CGFloat = Constants.Dimensions.defaultMargin
    var action: () -> Void
    var staticWidth: CGFloat?
    var isEnabled: Bool?

    var body: some View {
        Button(action: {
            if isEnabled ?? true {
                action()
            }
        }) {
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, horizontalPadding)
                .padding()
                .background(isEnabled != nil ? (isEnabled! ? style.backgroundColor : Color.gray) : style.backgroundColor)
                .cornerRadius(24)
                .opacity(isEnabled != nil ? (isEnabled! ? 1.0 : 0.5) : 1.0)
        }
        .frame(maxWidth: .infinity)
        .disabled(isEnabled == nil ? false : !(isEnabled!))
    }
}

