//
//  Currencies.swift
//  Satodime
//
//  Created by Lionel Delvaux on 04/10/2023.
//

import Foundation
import SwiftUI

enum CryptoCurrency: String, CaseIterable, Identifiable {
    case bitcoin
    case ethereum
    case litecoin
    case bitcoinCash
    // case binance // For later use
    case counterParty
    case polygon
    case empty
    case unknown

    var id: String { self.rawValue }
    
    init?(shortIdentifier: String) {
        // TODO: refactoring needed - Unify formatting in one place
        var formattedIdentifier = shortIdentifier.replacingOccurrences(of: "TEST", with: "").uppercased() //TODO: refactor?
        formattedIdentifier = formattedIdentifier.replacingOccurrences(of: "ROP", with: "ETH")
        for currency in CryptoCurrency.allCases {
            if currency.shortIdentifier == formattedIdentifier {
                self = currency
                return
            }
        }
        return nil
    }

    var icon: String {
        switch self {
        case .bitcoin:
            return "ic_coin_btc"
        case .ethereum:
            return "ic_coin_eth"
        case .litecoin:
            return "ic_coin_ltc"
        case .bitcoinCash:
            return "ic_coin_bch"
        // case .binance: // For later use
        //     return "ic_coin_bnb"
        case .polygon:
            return "ic_coin_polygon"
        case .counterParty:
            return "ic_coin_xcp"
        case .empty:
            return "ic_coin_empty" //TODO: create icon
        case .unknown:
            return "ic_coin_unknown" //TODO: create icon
        }
    }
    
    var name: String {
        switch self {
        case .bitcoin:
            return "Bitcoin"
        case .ethereum:
            return "Ethereum"
        case .litecoin:
            return "Litecoin"
        case .bitcoinCash:
            return "BitcoinCash"
        // case .binance: // For later use
        //     return "Binance"
        case .polygon:
            return "Polygon"
        case .counterParty:
            return "Counterparty"
        case .empty:
            return "(Uninitialized)"
        case .unknown:
            return "(Unknown)"
        }
    }
    
    var shortIdentifier: String {
        switch self {
        case .bitcoin:
            return "BTC"
        case .ethereum:
            return "ETH"
        case .litecoin:
            return "LTC"
        case .bitcoinCash:
            return "BCH"
        // case .binance: // For later use
        //     return "BNB"
        case .polygon:
            return "MATIC"
        case .counterParty:
            return "XCP"
        case .empty:
            return "N/A"
        case .unknown:
            return "??"
        }
    }
    
    var color: Color {
        switch self {
        case .bitcoin:
            Color(hex: 0xFF9900)
        case .ethereum:
            Color(hex: 0x244ABD)
        case .litecoin:
            Color(hex: 0xABADB0)
        case .bitcoinCash:
            Color(hex: 0x35B795)
        // case .binance: // For later use
        //     Color(hex: 0xF3BA2F)
        case .polygon:
            Color(hex: 0x8247E5)
        case .counterParty:
            Color(hex: 0xD93554)
        case .empty:
            Color(hex: 0xD93554)//TODO
        case .unknown:
            Color(hex: 0xD93554)//TODO
        }
    }
    
    var slip44: UInt32 {
        switch self {
        case .bitcoin:
            return 0x80000000
        case .ethereum:
            return 0x8000003c
        case .litecoin:
            return 0x80000002
        case .bitcoinCash:
            return 0x80000091
        case .polygon:
            return 0x800003c6
        case .counterParty:
            return 0x80000009
        case .empty:
            return 0xdeadbeef
        case .unknown:
            return 0xffffffff //?
        }
    }
    
    var title: String {
        return self.rawValue.uppercased()
    }
    
    // can the cryptoCurrency by shown in list of crypto in sealing screen
    var isShowable: Bool {
        return (self != .empty) && (self != .unknown)
    }
}
