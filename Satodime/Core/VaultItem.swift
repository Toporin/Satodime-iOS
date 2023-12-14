//
//  VaultItem.swift
//  Satodime for iOS
//
//  Created by Satochip on 21/01/2023.
//  Copyright © 2023 Satochip S.R.L.
//
import Foundation
import CoreGraphics
import SatochipSwift
import SwiftCryptoTools

public struct VaultItem: Hashable {
    
    public static func == (lhs: VaultItem, rhs: VaultItem) -> Bool {
        return lhs.index == rhs.index // todo?
    }
    public func hash(into hasher: inout Hasher) {
            hasher.combine(index)
    }
    
    public static var apiKeys: [String:String] {
        get {
            guard let url = Bundle.main.url(forResource:"Apikeys-Info", withExtension: "plist") else {
            //guard let filePath = Bundle.main.path(forResource: "Apikeys-Info", ofType: "plist") else {
                print("Couldn't find file 'Apikeys-Info.plist'")
                return [String:String]()
            }
            do {
                let data = try Data(contentsOf:url)
                let swiftDictionary = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String:String]
                print("swiftDictionary: \(swiftDictionary)")
                return swiftDictionary
            } catch {
                print(error)
                return [String:String]()
            }
        }
    }
    
    public var index: UInt8
    public var coin: BaseCoin
    var coinMeta: CryptoCurrency = CryptoCurrency.empty
    public var iconPath: String = "ic_coin_unknown" // TODO: deprecate, use coinMeta instead
    public var keyslotStatus: SatodimeKeyslotStatus
    
    // coin info
    public var pubkey: [UInt8]? = nil
    public var balance: Double? = nil // async value
    public var address: String = "(undefined)" 
//    {
//        didSet { // TODO: remove??
//            print("** didSet VaultItem address: \(address)")
//            if address == "(unsupported)" {
//                print("unsupported coin")
//            }
//        }
//    }
    public var addressUrl: URL? = nil // explorer url
    
    public var selectedFirstCurrency: String? = nil
    public var selectedSecondCurrency: String? = nil
    public var coinValueInFirstCurrency: Double? = nil
    public var coinValueInSecondCurrency: Double? = nil
    
    // asset list
    public var tokenList: [[String:String]]? = nil
    public var nftList: [[String:String]]? = nil
    // total value in tokens (excluding main coin)
    public var totalTokenValueInFirstCurrency: Double? = nil
    public var totalTokenValueInSecondCurrency: Double? = nil
    // total value (including main coin)
    public var totalValueInFirstCurrency: Double? = nil
    public var totalValueInSecondCurrency: Double? = nil
    
    // private info
    var privkey: [UInt8]? = nil
    var entropy: [UInt8]? = nil
    
    public init(index: UInt8, keyslotStatus: SatodimeKeyslotStatus){
        self.index = index
        self.keyslotStatus = keyslotStatus
        
        let slip44: UInt32
        if keyslotStatus.status == 0x00 { // hack: uninitialized slot
            slip44 = 0xdeadbeef
        } else {
            slip44 = keyslotStatus.slip44
        }
        let isTestnet = ((slip44 & 0x80000000)==0x00000000) ? true : false
        let slip44WithoutTestnetBit = (slip44 | 0x80000000)
        switch slip44WithoutTestnetBit {
        case 0x80000000:
            coin = Bitcoin(isTestnet: isTestnet, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_btc"
            coinMeta = .bitcoin
        case 0x80000002:
            coin = Litecoin(isTestnet: isTestnet, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_ltc"
            coinMeta = .litecoin
        case 0x80000009:
            coin = Counterparty(isTestnet: isTestnet, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_xcp"
            coinMeta = .counterParty
        case 0x8000003c:
            coin = Ethereum(isTestnet: isTestnet, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_eth"
            coinMeta = .ethereum
        case 0x80000091:
            coin = BitcoinCash(isTestnet: isTestnet, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_bch"
            coinMeta = .bitcoinCash
//        case 0x8000232e:
//            coin = BinanceSmartChain(isTestnet: isTestnet, apiKeys: VaultItem.apiKeys)
//            iconPath = "ic_coin_bnb"
        case 0xdeadbeef: // uninitialized slot!
            coin = EmptyCoin(isTestnet: isTestnet, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_empty"
            coinMeta = .empty
        default:
            coin = UnsupportedCoin(isTestnet: isTestnet, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_unknown"
            coinMeta = .unknown
        }
    }
    
    public func isInitialized() -> Bool {
        let result = self.keyslotStatus.status != 0x00 || self.keyslotStatus.status != 0
        return result
    }
    
    public func isSealed() -> Bool {
        return self.keyslotStatus.status == 0x01
    }
    
    public func getStatus() -> SealStatus {
        switch self.keyslotStatus.status {
        case 0x01:
            return .sealed
        case 0x02:
            return .unsealed
        default:
            return .uninitialized
        }
    }
    
    // MARK: Public & Private keys Helpers
    public func getPublicKeyString() -> String {
        if let key = self.pubkey {
            return self.coin.keyBytesToString(keyBytes: key)
        } else {
            return "N/A"
        }
    }
    
    public func getPrivateKeyString() -> String {
        if let key = self.privkey {
            return self.coin.keyBytesToString(keyBytes: key)
        } else {
            return "N/A"
        }
    }
    
    public func getWifString() -> String {
        if let key = self.privkey {
            return self.coin.encodePrivkey(privkey: key)
        } else {
            return "N/A"
        }
    }
    
    public func getEntropyString() -> String {
        if let entropy = self.entropy {
            return self.coin.keyBytesToString(keyBytes: entropy)
        } else {
            return "N/A"
        }
    }
    
}
