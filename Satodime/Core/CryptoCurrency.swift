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
    case binance
    case counterParty

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .bitcoin:
            return "ic_btc"
        case .ethereum:
            return "ic_eth"
        case .litecoin:
            return "ic_ltc"
        case .bitcoinCash:
            return "ic_btc_cash"
        case .binance:
            return "ic_bnb"
        case .counterParty:
            return "ic_xcp"
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
        case .binance:
            return "Binance"
        case .counterParty:
            return "Counterparty"
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
        case .binance:
            return "BNB"
        case .counterParty:
            return "XCP"
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
        case .binance:
            Color(hex: 0xF3BA2F)
        case .counterParty:
            Color(hex: 0xD93554)
        }
    }
    
    var title: String {
        return self.rawValue.uppercased()
    }
}
