//
//  SatoText.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import SwiftUI

enum SatoTextStyle {
    case title
    case subtitle
    case subtitleBold
    case viewTitle
    case cellTitle
    case slotTitle
    case addressText
    case balanceLarge
    
    var lineHeight: CGFloat {
        switch self {
        case .title:
            return 38
        case .subtitle:
            return 20
        case .subtitleBold:
            return 20
        case .viewTitle:
            return 36
        case .cellTitle:
            return 20
        case .slotTitle:
            return 57
        case .addressText:
            return 19
        case .balanceLarge:
            return 35
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .title:
            return 30
        case .subtitle:
            return 15
        case .subtitleBold:
            return 16
        case .viewTitle:
            return 24
        case .cellTitle:
            return 16
        case .slotTitle:
            return 45
        case .addressText:
            return 14
        case .balanceLarge:
            return 28
        }
    }

    var font: Font {
        switch self {
        case .title, .cellTitle, .balanceLarge:
            return .custom("Outfit-Medium", size: self.fontSize)
        case .subtitle:
            return .custom("OpenSans-variable", size: self.fontSize)
        case .viewTitle:
            return .custom("Poppins-ExtraBold", size: self.fontSize)
        case .subtitleBold:
            return .custom("Outfit-Bold", size: self.fontSize)
        case .slotTitle:
            return .custom("Outfit-ExtraLight", size: self.fontSize)
        case .addressText:
            return .custom("OpenSans-SemiBold", size: self.fontSize)
        }
    }

    var textColor: Color {
        switch self {
        case .title:
            return .white
        case .subtitle:
            return .white
        case .subtitleBold:
            return .white
        case .viewTitle:
            return .white
        case .cellTitle:
            return .white
        case .slotTitle:
            return .white
        case .addressText:
            return Constants.Colors.addressText
        case .balanceLarge:
            return .white
        }
    }

    var fontWeight: Font.Weight {
        switch self {
        case .title, .subtitleBold:
            return .bold
        case .subtitle, .cellTitle:
            return .regular
        case .viewTitle:
            return .bold
        case .slotTitle:
            return .ultraLight
        case .addressText:
            return .semibold
        case .balanceLarge:
            return .medium
        }
    }
}


struct SatoText: View {
    var text: String
    var style: SatoTextStyle
    var alignment: TextAlignment = .center

    var body: some View {
        Text(.init(text))
            .font(style.font.weight(style.fontWeight))
            .lineSpacing(style.lineHeight - style.fontSize)
            .multilineTextAlignment(alignment)
            .foregroundColor(style.textColor)
    }
}
