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
//import QRCode

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

    public static let assetDict: [UInt8 : String] =
                                   [0x00 : "Empty",
                                    0x01 : "Coin",
                                    0x10 : "Token",
                                    0x11 : "ERC20",
                                    0x12 : "BEP20",
                                    0x40 : "NFT",
                                    0x41 : "ERC721",
                                    0x42 : "BEP721",
                                    0xFF : "Other",]
    
    public static let statusDict: [UInt8 : String] =
                                   [0x00 : "Uninitialized",
                                    0x01 : "Sealed",
                                    0x02 : "Unsealed",]
    
    public static let nftSet: Set<UInt8> = [0x40, 0x41, 0x42]
    public static let tokenSet: Set<UInt8> = nftSet.union([0x10, 0x11, 0x12]) // a NFT is also a token
    
    public var index: UInt8
    public var coin: BaseCoin
    public var iconPath: String = "ic_coin_unknown"
    public var keyslotStatus: SatodimeKeyslotStatus
    
    // coin info
    public var pubkey: [UInt8]? = nil
    public var balance: Double? = nil // async value
    public var address: String = "(undefined)"
    public var addressUrl: URL? = nil
    
    // token
    public var tokenBalance: Double? = nil // async value
    public var tokenInfo: [String:String] = [:] // async value
    public var tokenUrl: URL? = nil
    // NFT
    public var nftInfo: [String:String] = [:] // async value
    public var nftUrl: URL? = nil
    
    // fiat value
    public var exchangeRate: Double? = nil
    public var tokenExchangeRate: Double? = nil
    public var otherCoinSymbol: String? = nil
    
    // private info
    var privkey: [UInt8]? = nil
    var entropy: [UInt8]? = nil
    
    //public init(slip44: UInt32){
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
        switch slip44 {
        case 0x80000000:
            coin = Bitcoin(isTestnet: false, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_btc"
        case 0x00000000:
            coin = Bitcoin(isTestnet: true, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_btctest"
        case 0x80000002:
            coin = Litecoin(isTestnet: false, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_ltc"
        case 0x00000002:
            coin = Litecoin(isTestnet: true, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_ltctest"
        case 0x80000009:
            coin = Counterparty(isTestnet: false, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_xcp"
        case 0x00000009:
            coin = Counterparty(isTestnet: true, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_xcptest"
        case 0x8000003c:
            coin = Ethereum(isTestnet: false, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_eth"
        case 0x0000003c:
            coin = Ethereum(isTestnet: true, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_ethtest"
        case 0x80000091:
            coin = BitcoinCash(isTestnet: false, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_bch"
        case 0x00000091:
            coin = BitcoinCash(isTestnet: true, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_bchtest"
        case 0xdeadbeef: // uninitialized slot!
            coin = EmptyCoin(isTestnet: true, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_empty"
        default:
            coin = UnsupportedCoin(isTestnet: isTestnet, apiKeys: VaultItem.apiKeys)
            if isTestnet {
                iconPath = "ic_coin_unknowntest"
            }
            else {
                iconPath = "ic_coin_unknown"
            }
        }
    }
    
    public func getStatusString() -> String {
        let statusByte: UInt8 = keyslotStatus.status
        let statusString = VaultItem.statusDict[statusByte] ?? String(statusByte) //"Undefined"
        return statusString
    }
    
    public func getAssetString() -> String {
        let assetByte: UInt8 = keyslotStatus.asset
        let assetString: String = VaultItem.assetDict[assetByte] ?? String(assetByte) //"Undefined"
        return assetString
    }
    
    public func isNft() -> Bool {
        let assetByte: UInt8 = keyslotStatus.asset
        if VaultItem.nftSet.contains(assetByte) {
            return true
        } else {
            return false
        }
    }
    
    public func isToken() -> Bool {
        let assetByte: UInt8 = keyslotStatus.asset
        if VaultItem.tokenSet.contains(assetByte) {
            return true
        } else {
            return false
        }
    }
    
    
    // TODO
    // coin info
    public func getPublicKeyString() -> String {
        if let key = self.pubkey {
            return self.coin.keyBytesToString(keyBytes: key)
        } else {
            return "N/A"
        }
    }
    
    public func getBlockchainString() -> String {
        return self.coin.displayName
    }
    
    // balance info
    public func getBalanceString() -> String {
        print("in getBalanceString balance: \(self.balance ?? Double.nan)")
        var balanceString: String = ""
        if let balance = self.balance {
            balanceString = String(balance)
        } else {
            print("Debug balance is nil!")
            balanceString = "? "
        }
        balanceString += " " + self.getDenominationString() + " " + self.getFiatValueString()
        return balanceString
    }
    
    public func getDenominationString() -> String {
        let denominationString = self.coin.displayName + " (\(self.coin.coinSymbol))"
        return denominationString
    }
    
    public func getFiatValueString() -> String {
        let fiatValueString: String
        if let balance = self.balance,
           let exchangeRate = self.exchangeRate,
           let otherCoinSymbol = self.otherCoinSymbol {
            let fiatValue = balance * exchangeRate
            fiatValueString = "(~" + String(fiatValue) + " " + otherCoinSymbol + ")"
        } else {
            fiatValueString = ""
        }
        return fiatValueString
    }
    
    // token/NFT info
    public func getContractString() -> String {
        return self.coin.contractBytesToString(contractBytes: self.keyslotStatus.contract)
    }
    
    public func getNftTokenidString() -> String {
        return self.coin.tokenidBytesToString(tokenidBytes: self.keyslotStatus.tokenid)
    }
    
    public func getNftNameString() -> String {
        let name = nftInfo["nftName"] ?? ""
        return name
    }
    
    public func getNftDescriptionString() -> String {
        return nftInfo["nftDescription"] ?? ""
    }
    public func getNftImageUrlString() -> String {
        var nftImageUrlString = nftInfo["nftImageUrl"] ?? ""
        // check if IPFS? => use ipfs.io gateway
        // todo: support ipfs protocol
        if nftImageUrlString.hasPrefix("ipfs://ipfs/") {
            // ipfs://ipfs/bafybeia4kfavwju5gjjpilerm2azdoxvpazff6fmtatqizdpbmcolpsjci/image.png
            // https://ipfs.io/ipfs/bafybeia4kfavwju5gjjpilerm2azdoxvpazff6fmtatqizdpbmcolpsjci/image.png
            nftImageUrlString = String(nftImageUrlString.dropFirst(6)) // remove "ipfs:/"
            nftImageUrlString = "https://ipfs.io" + nftImageUrlString
        } else if nftImageUrlString.hasPrefix("ipfs://")  {
            // ipfs://QmZ2ddtVUV1brVGjpq6vgrG6jEgEK3CqH19VURKzdwCSRf
            // https://ipfs.io/ipfs/QmZ2ddtVUV1brVGjpq6vgrG6jEgEK3CqH19VURKzdwCSRf
            nftImageUrlString = String(nftImageUrlString.dropFirst(6)) // remove "ipfs:/"
            nftImageUrlString = "https://ipfs.io/ipfs" + nftImageUrlString
        }
        print("nftImageUrlString: \(nftImageUrlString)")
        return nftImageUrlString
    }
    
    // token balance info
    public func getTokenBalanceString() -> String {
        var balanceString: String = ""
        if let balance = self.tokenBalance {
            balanceString = String(balance)
        } else {
            balanceString = "? "
        }
        balanceString += " " + self.getTokenDenominationString() + " " + self.getTokenFiatValueString()
        return balanceString
    }
    
    public func getTokenDenominationString() -> String {
        let denominationString = (self.tokenInfo["name"] ?? "?") + " " + "(\(self.tokenInfo["symbol"] ?? "?"))"
        return denominationString
    }
    
    public func getTokenFiatValueString() -> String {
        let fiatValueString: String
        if let balance = self.tokenBalance,
           let exchangeRate = self.tokenExchangeRate,
           let otherCoinSymbol = self.otherCoinSymbol {
            let fiatValue = balance * exchangeRate
            fiatValueString = "(~" + String(fiatValue) + " " + otherCoinSymbol + ")"
        } else {
            fiatValueString = ""
        }
        return fiatValueString
    }
    
    // private info
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
    
//    // util
//    public func getQRfromText(text: String) -> CGImage? {
//        let doc = QRCode.Document(utf8String: text, errorCorrection: .high)
//        let generated = doc.cgImage(CGSize(width: 800, height: 800))
//        return generated
//    }
    
}
