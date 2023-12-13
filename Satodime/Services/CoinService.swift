//
//  CoinService.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//

import Foundation

// TODO: Needs refactoring
// MARK: - Data

struct AssetsResult {
    // TODO:
    // coin: [String:String]
    // totalValueInFirstCurrency: Double
    // firstCurrency: String
    // totalValueInSecondCurrency: Double
    // secondCurrency: String
    let mainCryptoBalance: Double
    let mainCryptoFiatBalance: String
    let nftList: [[String:String]]
    let tokenList: [[String:String]]
}

// MARK: - Protocol

protocol PCoinService {
    func fetchCryptoBalance(for coinInfo: VaultItem) async -> Double
    func fetchCryptoTotalBalance(for coinInfo: VaultItem) async -> Double
    func fetchFiatBalance(for coinInfo: VaultItem, with cryptoBalance: Double) async -> String
    func fetchAssets(for coinInfo: VaultItem) async -> AssetsResult
}

// MARK: - Service

class CoinService: PCoinService {
    //let logger = ConsoleLogger()
    let logger = LoggerService.shared
    //@EnvironmentObject var logger: LoggerService
    let preferenceService = PreferencesService()
    
    func fetchCryptoBalance(for coinInfo: VaultItem) async -> Double {
        var address = coinInfo.address
        #if DEBUG
        if coinInfo.coin.coinSymbol == "XCP" {
            //address = "1Do5kUZrTyZyoPJKtk4wCuXBkt5BDRhQJ4" // nft
            //address = "1DvNiQkdX7HN7UJpMNWsnWLizEJSxXzgCp" // lots of nft + xcp
        } else if coinInfo.coin.coinSymbol == "ETH" {
            //address = "0xd5b06c8c83e78e92747d12a11fcd0b03002d48cf"
            //address = "0x86b4d38e451c707e4914ffceab9479e3a8685f98"
            //address = "0xE71a126D41d167Ce3CA048cCce3F61Fa83274535" // cryptopunk
            //address = "0xed1bf53Ea7fD8a290A3172B6c00F1Fb3657D538F" // usdt
        }
        #endif
        
        logger.log("fetching balance...")
        //logger2.debug("fetching balance...")
        var balance: Double = 0.0
        // let addressUrl = URL(string: coinInfo.coin.getAddressWebLink(address: address) ?? "")
        
        do {
            balance = try await coinInfo.coin.getBalance(addr: address)
        } catch {
            logger.error("Request failed with error: \(error)")
            logger.error("Coin: \(coinInfo.coin.coinSymbol)")
        }
        
        return balance
    }
    
    func fetchCryptoTotalBalance(for coinInfo: VaultItem) async -> Double {
        var address = coinInfo.address
        #if DEBUG
        if coinInfo.coin.coinSymbol == "XCP" {
            //address = "1Do5kUZrTyZyoPJKtk4wCuXBkt5BDRhQJ4" // nft
            //address = "1DvNiQkdX7HN7UJpMNWsnWLizEJSxXzgCp" // nft + xcp
        } else if coinInfo.coin.coinSymbol == "ETH" {
            //address = "0xd5b06c8c83e78e92747d12a11fcd0b03002d48cf"
            //address = "0x86b4d38e451c707e4914ffceab9479e3a8685f98"
            //address = "0xE71a126D41d167Ce3CA048cCce3F61Fa83274535" // cryptopunk
            //address = "0xed1bf53Ea7fD8a290A3172B6c00F1Fb3657D538F" // usdt
        }
        #endif
        
        logger.log("fetching balance...")
        var balance: Double = 0.0
        // let addressUrl = URL(string: coinInfo.coin.getAddressWebLink(address: address) ?? "")
        
        // TODO: duplicate code!
        do {
            balance = try await coinInfo.coin.getBalance(addr: address)
        } catch {
            logger.error("Request failed with error: \(error)")
            logger.error("Coin: \(coinInfo.coin.coinSymbol)")
        }
        
        let tokenBalance = await self.fetchTokensTotalBalance(for: coinInfo)
        
        let totalBalance = balance + tokenBalance
        
        return totalBalance
    }
    
    func fetchFiatBalance(for coinInfo: VaultItem, with cryptoBalance: Double) async -> String {
        let selectedSecondCurrency = self.preferenceService.getCurrency()
        var balance: Double = 0.0
        
        if let exchangeRate2 = await coinInfo.coin.getExchangeRateBetween(coin: coinInfo.coin.coinSymbol, otherCoin: selectedSecondCurrency){
            logger.info("exchangeRate: \(exchangeRate2) \(selectedSecondCurrency)")
            let coinValue = cryptoBalance * exchangeRate2
            logger.info("in fetchFiatBalance [\(index)] totalValueInSecondCurrency: \(coinValue)")
            balance = coinValue
        }
        
        return "\(String(format: "%.2f", balance)) \(selectedSecondCurrency)"
    }
    
    func fetchTokensTotalBalance(for coinInfo: VaultItem) async -> Double {
        let selectedFirstCurrency: String = coinInfo.coin.coinSymbol
        var selectedSecondCurrency: String = self.preferenceService.getCurrency()
        
        var address = coinInfo.address
        let assetList = await coinInfo.coin.getSimpleAssetList(addr: address)
        
        var totalTokenValueInFirstCurrency = 0.0
        var totalTokenValueInSecondCurrency = 0.0
        
        var tokenList: [[String:String]]=[]
        for asset in assetList {
            if let contract = asset["contract"]{
                var assetCopy = asset
                assetCopy["type"] = "token"
                
                // get price if available
                if let tokenBalance = coinInfo.getTokenBalanceDouble(tokenData: asset),
                   let tokenExchangeRate = Double(asset["tokenExchangeRate"] ?? ""),
                   let currencyForExchangeRate = asset["currencyForExchangeRate"] {
                    
                    assetCopy["tokenBalance"] = String(tokenBalance)
                    
                    if let currencyExchangeRate1 = await coinInfo.coin.getExchangeRateBetween(coin: currencyForExchangeRate, otherCoin: selectedFirstCurrency)
                    {
                        let tokenValueInFirstCurrency = tokenBalance * tokenExchangeRate * currencyExchangeRate1
                        totalTokenValueInFirstCurrency += tokenValueInFirstCurrency
                        assetCopy["tokenValueInFirstCurrency"] = String(tokenValueInFirstCurrency)
                        assetCopy["firstCurrency"] = selectedFirstCurrency
                        print("in fetchDataFromWeb tokenValueInFirstCurrency: \(tokenValueInFirstCurrency)")
                    }
                    
                }
                tokenList.append(assetCopy)
                print("NfcReader: added assetCopy: \(assetCopy)")
            } // if contract
        }// for asset

        print("NfcReader: tokenList: \(tokenList)")
        
        print("Total balance 1 : \(totalTokenValueInFirstCurrency) ")
        print("Total balance 2 : \(totalTokenValueInSecondCurrency) ")
        
        return totalTokenValueInFirstCurrency
    }
    
    func fetchAssets(for coinInfo: VaultItem) async -> AssetsResult {
        let selectedFirstCurrency: String = coinInfo.coin.coinSymbol
        var selectedSecondCurrency: String = self.preferenceService.getCurrency()
        
        var mainCryptoBalance = await self.fetchCryptoBalance(for: coinInfo)
        var mainCryptoFiatBalance = await self.fetchFiatBalance(for: coinInfo, with: mainCryptoBalance)
        
        var address = coinInfo.address
        #if DEBUG
        if coinInfo.coin.coinSymbol == "XCP" {
            //address = "1Do5kUZrTyZyoPJKtk4wCuXBkt5BDRhQJ4" // nft
            //address = "1DvNiQkdX7HN7UJpMNWsnWLizEJSxXzgCp" // nft + xcp
        } else if coinInfo.coin.coinSymbol == "ETH" {
            //address = "0xd5b06c8c83e78e92747d12a11fcd0b03002d48cf"
            //address = "0x86b4d38e451c707e4914ffceab9479e3a8685f98"
            //address = "0xE71a126D41d167Ce3CA048cCce3F61Fa83274535" // cryptopunk
            //address = "0xed1bf53Ea7fD8a290A3172B6c00F1Fb3657D538F" // usdt
        }
        #endif
        logger.info("Fetch asset for address: \(address)")
        
        let assetList = await coinInfo.coin.getSimpleAssetList(addr: address)
        logger.info("Asset list: \(assetList)")
        
        // sort assets between token and nfts
        // also get value if available
        var totalTokenValueInFirstCurrency = 0.0
        var totalTokenValueInSecondCurrency = 0.0
        var nftList: [[String:String]]=[]
        var tokenList: [[String:String]]=[]
        
        for asset in assetList {
            if let contract = asset["contract"]{
                var nftListByContract = await coinInfo.coin.getNftList(addr: address, contract: contract)
                
                if nftListByContract.count>0 { // nft
                    for nft in nftListByContract {
                        // we merge the asset & nft dicts to get the most info about the nft
                        var nftMerged = nft.merging(asset, uniquingKeysWith: { (first, _) in first })
                        nftMerged["type"] = "nft"
                        nftList.append(nftMerged)
                        logger.debug("NfcReader: added nftMerged: \(nftMerged)")
                        
                        // TODO: fetch price
                    }
                } else { // token
                    var assetCopy = asset
                    assetCopy["type"] = "token"
                    
                    // get price if available
                    if let tokenBalance = coinInfo.getTokenBalanceDouble(tokenData: asset),
                        let tokenExchangeRate = Double(asset["tokenExchangeRate"] ?? ""),
                        let currencyForExchangeRate = asset["currencyForExchangeRate"] {
                        
                        print("in fetchDataFromWeb tokenBalance: \(tokenBalance)")
                        print("in fetchDataFromWeb tokenExchangeRate: \(tokenExchangeRate)")
                        print("in fetchDataFromWeb currencyForExchangeRate: \(currencyForExchangeRate)")
                        
                        // selectedFirstCurrency
                        // TODO: cache result?
                        if let currencyExchangeRate1 = await coinInfo.coin.getExchangeRateBetween(coin: currencyForExchangeRate, otherCoin: selectedFirstCurrency)
                        {
                            print("in fetchDataFromWeb currencyExchangeRate1: \(currencyExchangeRate1)")
                            print("in fetchDataFromWeb selectedFirstCurrency: \(selectedFirstCurrency)")
                            
                            let tokenValueInFirstCurrency = tokenBalance * tokenExchangeRate * currencyExchangeRate1
                            totalTokenValueInFirstCurrency += tokenValueInFirstCurrency
                            assetCopy["tokenValueInFirstCurrency"] = String(tokenValueInFirstCurrency)
                            assetCopy["firstCurrency"] = selectedFirstCurrency
                            print("in fetchDataFromWeb tokenValueInFirstCurrency: \(tokenValueInFirstCurrency)")
                        }
                        
                        // second currency
                        if let currencyExchangeRate2 = await coinInfo.coin.getExchangeRateBetween(coin: currencyForExchangeRate, otherCoin: selectedSecondCurrency)
                        {
                            let tokenValueInSecondCurrency = tokenBalance * tokenExchangeRate * currencyExchangeRate2
                            totalTokenValueInSecondCurrency += tokenValueInSecondCurrency
                            assetCopy["tokenValueInSecondCurrency"] = String(tokenValueInSecondCurrency)
                            assetCopy["secondCurrency"] = selectedSecondCurrency
                        }
                    } // if token balance
//                    else {
//                        // DEBUG
//                        print("in fetchDataFromWeb ERROR no balance available")
//                        print("asset: \(asset)")
//                        print(coinInfo.getTokenBalanceDouble(tokenData: asset))
//                        print(Double(asset["tokenExchangeRate"] ?? ""))
//                        print(asset["currencyForExchangeRate"])
//                        print("---------")
//                    }
                    
                    tokenList.append(assetCopy)
                    print("NfcReader: added assetCopy: \(assetCopy)")
                } // if nft else token
            } // if contract
        } // for asset
        
        
        
        //old
//        for asset in assetList {
//            if let contract = asset["contract"]{
//                var assetCopy = asset
//                assetCopy["type"] = "token"
//                
//                // get price if available
//                if let tokenBalance = coinInfo.getTokenBalanceDouble(tokenData: asset),
//                    let tokenExchangeRate = Double(asset["tokenExchangeRate"] ?? ""),
//                    let currencyForExchangeRate = asset["currencyForExchangeRate"] {
//                    
//                    assetCopy["tokenBalance"] = String(tokenBalance)
//                    
//                    print("in fetchDataFromWeb [\(index)] tokenBalance: \(tokenBalance)")
//                    print("in fetchDataFromWeb [\(index)] tokenExchangeRate: \(tokenExchangeRate)")
//                    print("in fetchDataFromWeb [\(index)] currencyForExchangeRate: \(currencyForExchangeRate)")
//                    
//                    // selectedFirstCurrency
//                    // TODO: cache result?
//                    if let currencyExchangeRate1 = await coinInfo.coin.getExchangeRateBetween(coin: currencyForExchangeRate, otherCoin: selectedFirstCurrency)
//                    {
//                        print("in fetchDataFromWeb [\(index)] currencyExchangeRate1: \(currencyExchangeRate1)")
//                        print("in fetchDataFromWeb [\(index)] selectedFirstCurrency: \(selectedFirstCurrency)")
//                        
//                        let tokenValueInFirstCurrency = tokenBalance * tokenExchangeRate * currencyExchangeRate1
//                        totalTokenValueInFirstCurrency += tokenValueInFirstCurrency
//                        assetCopy["tokenValueInFirstCurrency"] = String(tokenValueInFirstCurrency)
//                        assetCopy["firstCurrency"] = selectedFirstCurrency
//                        print("in fetchDataFromWeb tokenValueInFirstCurrency: \(tokenValueInFirstCurrency)")
//                    }
//                    
//                    // second currency
//                    if let currencyExchangeRate2 = await coinInfo.coin.getExchangeRateBetween(coin: currencyForExchangeRate, otherCoin: selectedSecondCurrency)
//                    {
//                        let tokenValueInSecondCurrency = tokenBalance * tokenExchangeRate * currencyExchangeRate2
//                        totalTokenValueInSecondCurrency += tokenValueInSecondCurrency
//                        assetCopy["tokenValueInSecondCurrency"] = String(tokenValueInSecondCurrency)
//                        assetCopy["secondCurrency"] = selectedSecondCurrency
//                    }
//                }// if tokenBalance
//                
//                tokenList.append(assetCopy)
//                print("NfcReader: added assetCopy: \(assetCopy)")
//            } // if contract
//        } // for asset
        
//        // TODO: contract is not needed ?
//        var nftListByContract = await coinInfo.coin.getNftList(addr: address, contract: "")
//        
//        if nftListByContract.count>0 { // nft
//            for nft in nftListByContract {
//                // var nftMerged = nft.merging(asset, uniquingKeysWith: { (first, _) in first })
//                var nftMerged: [String:String] = [:]
//                nftMerged["nftImageUrl"] = nft["nftImageUrl"]
//                nftMerged["type"] = "nft"
//                nftList.append(nftMerged)
//            }
//        }

        logger.debug("TokenList: \(tokenList)", tag: "CoinService")
        logger.debug("NftList: \(nftList)", tag: "CoinService")
        
        logger.debug("Total balance 1 : \(totalTokenValueInFirstCurrency) ")
        logger.debug("Total balance 2 : \(totalTokenValueInSecondCurrency) ")
        let result = AssetsResult(
            mainCryptoBalance: mainCryptoBalance,
            mainCryptoFiatBalance: mainCryptoFiatBalance,
            nftList: nftList,
            tokenList: tokenList)
        
        return result
    }
}
