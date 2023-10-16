//
//  QRCode.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import CoreGraphics
import QRCode
import SwiftUI

class QRCodeHelper {
    public func getQRfromText(text: String) -> CGImage? {
        let doc = QRCode.Document(utf8String: text, errorCorrection: .high)
        doc.design.foregroundColor(Color.black.cgColor!)
        doc.design.backgroundColor(Color.white.cgColor!)
        let generated = doc.cgImage(CGSize(width: 250, height: 250))
        return generated
    }
}
