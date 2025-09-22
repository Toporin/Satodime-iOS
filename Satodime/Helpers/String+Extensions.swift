//
//  String+Extensions.swift
//  Satodime
//
//  Created by Satochip on 19/09/2025.
//

import Foundation

// MARK: - Utility Functions
extension String {
    /// Converts a string to a 20-byte array using UTF8 encoding
    /// - Pads with 0x00 bytes if the string is shorter than 20 bytes
    /// - Truncates if the string is longer than 20 bytes
    /// - Returns: Array of exactly 20 UInt8 bytes
    func toFixedByteArray(length: Int = 20) -> [UInt8] {
        let utf8Data = self.data(using: .utf8) ?? Data()
        var byteArray = Array(utf8Data)
        
        if byteArray.count > length {
            // Truncate if too long
            byteArray = Array(byteArray.prefix(length))
        } else if byteArray.count < length {
            // Pad with 0x00 bytes if too short
            let paddingNeeded = length - byteArray.count
            byteArray.append(contentsOf: Array(repeating: 0x00, count: paddingNeeded))
        }
        
        return byteArray
    }
}
