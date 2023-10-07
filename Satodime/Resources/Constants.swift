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
        static let informButtonBackground = Color(hex: 0x525684)
        static let confirmButtonBackground = Color(hex: 0x24B59B)
        static let cellBackground = Color(hex: 0x3E4160)
        static let unsealedStatusText = Color(hex: 0xFFB444)
        static let sealedStatusText = Color(hex: 0x64FFC7)
        static let addressText = Color(hex: 0xD6D6D6)
    }
    
    // MARK: - Dimensions
    struct Dimensions {
        // MARK: - Margins
        static let defaultMargin: CGFloat = 16.0
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
        static let isFirstUse = "IS_FIRST_USE"
    }
    
    // MARK: - URLs
    struct Links {
        static let moreInfo = "https://satochip.io/product/satodime/"
    }
}
