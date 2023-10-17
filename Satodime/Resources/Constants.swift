//
//  Constants.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI

struct Constants {
    
    // MARK: - Colors
    struct Colors {
        static let viewBackground = Color(hex: 0x292B3D)
        static let errorViewBackground = Color(hex: 0x56213E)
        static let informButtonBackground = Color(hex: 0x525684)
        static let confirmButtonBackground = Color(hex: 0x24B59B)
        static let cellBackground = Color(hex: 0x3E4160)
        static let unsealedStatusText = Color(hex: 0xFFB444)
        static let sealedStatusText = Color(hex: 0x64FFC7)
        static let addressText = Color(hex: 0xD6D6D6)
        static let satoListBackground = Color(hex: 0x37374F)
        static let ledGreen = Color(hex: 0x64FFC7)
        static let darkLedGreen = Color(hex: 0x24B59B)
        static let separator = Color(hex: 0x585D72)
        static let ledRed = Color(hex: 0xFF2D52)
        static let ledBlue = Color(hex: 0x65BBE0)
        static let lightGray = Color(hex: 0xFBFBFB)
        static let grayMenuButton = Color(hex: 0x65889C)
        static let greenMenuButton = Color(hex: 0x5FB4B4)
        static let blueMenuButton = Color(hex: 0x485979)
        static let darkBlueMenuButton = Color(hex: 0x2D2F46)
        static let unsealTextColor = Color(hex: 0x9F76A1)
        static let resetTextColor = Color(hex: 0xFF2D52)
    }
    
    // MARK: - Dimensions
    struct Dimensions {
        // MARK: - Margins
        static let defaultMargin: CGFloat = 16.0
        static let smallSideMargin: CGFloat = 20.0
        static let defaultSideMargin: CGFloat = 35.0
        static let defaultBottomMargin: CGFloat = 47.0
        
        // MARK: - Spacing
        static let verticalIllustrationSpacing: CGFloat = 13.0
        static let subtitleSpacing: CGFloat = 23.0
        static let verticalLogoSpacing: CGFloat = 37.0
        
        // MARK: - Sizes
        static let satoDimeLogoHeight: CGFloat = 81.0
    }
    
    // MARK: - Storage
    struct Storage {
        static let isAppPreviouslyLaunched = "IS_APP_PREVIOUSLY_LAUNCHED"
        static let secondCurrency = "secondCurrency"
    }
    
    // MARK: - URLs
    struct Links {
        static let moreInfo = "https://satochip.io/product/satodime/"
    }
    
    // MARK: - Slots
    struct Slots {
        static let maxCardSlots = 3
    }
    
    // MARK: - Settings
    struct Settings {
        static let currencies = ["EUR", "USD", "BTC", "ETH"]
    }
}
