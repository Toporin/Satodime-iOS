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
    
    public static let statusDict: [UInt8 : String] =
                                   [0x00 : "Uninitialized",
                                    0x01 : "Sealed",
                                    0x02 : "Unsealed",]
    
    public var index: UInt8
    public var coin: BaseCoin
    public var iconPath: String = "ic_coin_unknown"
    public var keyslotStatus: SatodimeKeyslotStatus
    
    // coin info
    public var pubkey: [UInt8]? = nil
    public var balance: Double? = nil // async value
    public var address: String = "(undefined)" {
        didSet {
            print("** didSet VaultItem address: \(address)")
            if address == "(unsupported)" {
                print("unsupported coin")
            }
        }
    }
    public var addressUrl: URL? = nil // explorer url
    
    // deprecated fiat value
    //public var otherCoinSymbol: String? = nil
    //public var exchangeRate: Double? = nil
    //public var tokenExchangeRate: Double? = nil
    
    public var selectedFirstCurrency: String? = nil
    public var selectedSecondCurrency: String? = nil
    public var coinValueInFirstCurrency: Double? = nil
    public var coinValueInSecondCurrency: Double? = nil
    
    // asset list
    public var tokenList: [[String:String]]? = nil
    public var nftList: [[String:String]]? = nil
    // fiat value
    public var totalTokenValueInFirstCurrency: Double? = nil
    public var totalTokenValueInSecondCurrency: Double? = nil
    
    // total
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
        case 0x8000232e:
            coin = BinanceSmartChain(isTestnet: false, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_bch" //todo
        case 0x0000232e:
            coin = BinanceSmartChain(isTestnet: true, apiKeys: VaultItem.apiKeys)
            iconPath = "ic_coin_bchtest" // todo
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
    
    public func isInitialized() -> Bool {
        let result = self.keyslotStatus.status != 0x00 || self.keyslotStatus.status != 0
        return result
    }
    
    public func isSealed() -> Bool {
        return self.keyslotStatus.status == 0x01
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
    
    //
    public func getTotalValueInFirstCurrencyString() -> String {
        var valueString = ""
        if let value = self.totalValueInFirstCurrency {
            valueString = String(value)
        } else {
            print("Debug balance is nil!")
            valueString = "? "
        }
        valueString += " " + self.getCoinDenominationString()
        return valueString
    }
    
    public func getTotalValueInSecondCurrencyString() -> String {
        var valueString = ""
        if let value = self.totalValueInSecondCurrency,
           let symbol = self.selectedSecondCurrency{
            valueString = String(value) + " " + symbol
        } else {
            //print("Debug balance is nil!")
            valueString = "? "
        }
        return valueString
    }
    
    // balance info
    public func getCoinBalanceString() -> String {
        //print("in getBalanceString balance: \(self.balance ?? Double.nan)")
        var balanceString: String = ""
        if let balance = self.balance {
            balanceString = String(balance)
        } else {
            //print("Debug balance is nil!")
            balanceString = "? "
        }
        balanceString += " " + self.getCoinDenominationString() + " " + self.getCoinValueInSecondCurrencyString()
        return balanceString
    }
    
    public func getCoinShortBalanceString() -> String {
        let result = " (\(self.coin.coinSymbol))"
        return result
    }
    
    public func getCoinDenominationString() -> String {
        let denominationString = self.coin.displayName + " (\(self.coin.coinSymbol))"
        return denominationString
    }
    
    public func getCoinSymbol() -> String {
        return self.coin.coinSymbol
    }
    
//    public func getFiatValueString() -> String {
//        let fiatValueString: String
//        if let balance = self.balance,
//           let exchangeRate = self.exchangeRate,
//           let otherCoinSymbol = self.otherCoinSymbol {
//            let fiatValue = balance * exchangeRate
//            fiatValueString = "(~" + String(fiatValue) + " " + otherCoinSymbol + ")"
//        } else {
//            fiatValueString = ""
//        }
//        return fiatValueString
//    }
    
    public func getCoinValueInSecondCurrencyString() -> String {
        if let balance = coinValueInSecondCurrency,
           let selectedSecondCurrency = selectedSecondCurrency {
            return "(~ \(balance) \(selectedSecondCurrency))"
        }else {
            return ""
        }
    }
    
    public func getNftImageUrlString(link: String) -> String {
        var nftImageUrlString = link
        // check if IPFS? => use ipfs.io gateway
        // todo: support ipfs protocol
        if nftImageUrlString.hasPrefix("ipfs://ipfs/") {
            //ipfs://ipfs/bafybeia4kfavwju5gjjpilerm2azdoxvpazff6fmtatqizdpbmcolpsjci/image.png
            //https://ipfs.io/ipfs/bafybeia4kfavwju5gjjpilerm2azdoxvpazff6fmtatqizdpbmcolpsjci/image.png
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
    
    public func getTokenBalanceDouble(tokenData: [String:String]) -> Double? {
        
        if let balanceString = tokenData["balance"] {
            let decimalsString = tokenData["decimals"] ?? "0"
            
            if let balanceDouble = Double(balanceString),
               let decimalsDouble = Double(decimalsString) {
                let balance = balanceDouble / pow(Double(10),decimalsDouble)
                return balance
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    // token balance info
    public func getTokenBalanceString(tokenData: [String:String]) -> String {
        
        let denomination = self.getTokenDenominationString(tokenData: tokenData)
        if let balanceDouble = self.getTokenBalanceDouble(tokenData: tokenData){
            let balanceString = String(balanceDouble) //todo: improve formatting
            return balanceString + " " + denomination + " " + self.getTokenValueInSecondCurrencyString(tokenData: tokenData)
        } else {
            // unknown
            return "?" + " " + denomination
        }
    }

    public func getTokenDenominationString(tokenData: [String:String]) -> String {
        //let denominationString = (tokenData["name"] ?? "?") + " " + "(\(tokenData["symbol"] ?? "?"))"
        var denominationString = ""
        if let tokenName = tokenData["name"] {
            denominationString += tokenName + " "
        }
        if let tokenSymbol = tokenData["symbol"] {
            denominationString += "(" + tokenSymbol + ") "
        }
        return denominationString
    }
    
//    public func getTokenFiatValueString(tokenData: [String:String]) -> String {
//        let fiatValueString: String
//        if let balance = self.getTokenBalanceDouble(tokenData: tokenData),
//           let exchangeRate = Double(tokenData["tokenExchangeRate"] ?? ""),
//           let otherCoinSymbol = tokenData["currencyExchangeRate"] {
//            let fiatValue = balance * exchangeRate
//            fiatValueString = "(~" + String(fiatValue) + " " + otherCoinSymbol + ")"
//            return fiatValueString
//        } else {
//            return ""
//        }
//    }
    
    public func getTokenValueInSecondCurrencyString(tokenData: [String:String]) -> String {
        if let tokenValueInSecondCurrency = tokenData["tokenValueInSecondCurrency"],
           let secondCurrency = tokenData["secondCurrency"]{
            return "(~ \(tokenValueInSecondCurrency) \(secondCurrency))"
        } else {
            return ""
        }
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
    
}
