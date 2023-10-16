//
//  SatoText.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import SwiftUI

enum SatoTextStyle {
    case title
    case lightTitle
    case subtitle
    case lightSubtitle
    case graySubtitle
    case graySubtitle18
    case subtitleBold
    case viewTitle
    case cellTitle
    case slotTitle
    case addressText
    case balanceLarge
    case cellSmallTitle
    
    var lineHeight: CGFloat {
        switch self {
        case .title:
            return 38
        case .subtitle, .lightSubtitle:
            return 20
        case .graySubtitle:
            return 20
        case .graySubtitle18:
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
        case .lightTitle:
            return 26
        case .cellSmallTitle:
            return 16
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .title:
            return 30
        case .subtitle:
            return 15
        case .graySubtitle:
            return 15
        case .graySubtitle18, .lightSubtitle:
            return 18
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
        case .lightTitle:
            return 24
        case .cellSmallTitle:
            return 14
        }
    }

    var font: Font {
        switch self {
        case .title, .cellTitle, .balanceLarge, .lightTitle, .cellSmallTitle:
            return .custom("Outfit-Medium", size: self.fontSize)
        case .subtitle:
            return .custom("OpenSans-variable", size: self.fontSize)
        case .viewTitle:
            return .custom("Poppins-ExtraBold", size: self.fontSize)
        case .subtitleBold:
            return .custom("Outfit-Bold", size: self.fontSize)
        case .slotTitle, .lightSubtitle, .graySubtitle, .graySubtitle18:
            return .custom("Outfit-ExtraLight", size: self.fontSize)
        case .addressText:
            return .custom("OpenSans-SemiBold", size: self.fontSize)
        }
    }

    var textColor: Color {
        switch self {
        case .title, .lightTitle:
            return .white
        case .subtitle, .lightSubtitle:
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
        case .graySubtitle, .graySubtitle18:
            return Constants.Colors.lightGray
        case .cellSmallTitle:
            return .white
        }
    }

    var fontWeight: Font.Weight {
        switch self {
        case .title, .subtitleBold:
            return .bold
        case .subtitle, .lightSubtitle, .cellTitle:
            return .regular
        case .viewTitle:
            return .bold
        case .slotTitle:
            return .ultraLight
        case .addressText:
            return .semibold
        case .balanceLarge, .lightTitle, .cellSmallTitle:
            return .medium
        case .graySubtitle, .graySubtitle18:
            return .regular
        }
    }
}


struct SatoText: View {
    var text: String
    var style: SatoTextStyle
    var alignment: TextAlignment = .center

    var body: some View {
        Text(.init(text))
            .font(style.font)
            .lineSpacing(style.lineHeight - style.fontSize)
            .multilineTextAlignment(alignment)
            .foregroundColor(style.textColor)
    }
}
