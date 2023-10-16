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
    let nftList: [[String:String]]
    let tokenList: [[String:String]]
}

// MARK: - Protocol

protocol PCoinService {
    func fetchCryptoBalance(for coinInfo: VaultItem) async -> Double
    func fetchFiatBalance(for coinInfo: VaultItem, with cryptoBalance: Double) async -> String
    func fetchAssets(for coinInfo: VaultItem) async -> AssetsResult
}

// MARK: - Service

class CoinService: PCoinService {
    let logger = ConsoleLogger()
    let preferenceService = PreferencesService()
    
    func fetchCryptoBalance(for coinInfo: VaultItem) async -> Double {
        let address = coinInfo.address
        
        logger.log("fetching balance...")
        var balance: Double = 0.0
        let addressUrl = URL(string: coinInfo.coin.getAddressWebLink(address: address) ?? "")
        
        do {
            balance = try await coinInfo.coin.getBalance(addr: address)
        } catch {
            logger.error("Request failed with error: \(error)")
            logger.error("Coin: \(coinInfo.coin.coinSymbol)")
        }
        
        return balance
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
        
        return "\(balance) \(selectedSecondCurrency)"
    }
    
    func fetchAssets(for coinInfo: VaultItem) async -> AssetsResult {
        let selectedFirstCurrency: String = coinInfo.coin.coinSymbol
        var selectedSecondCurrency: String = self.preferenceService.getCurrency()
        #if DEBUG
        var address = "0x72eb30D3ca53f5e839325E2eACf535E70a9e6987"
        let assetList = [["contract":"0xEEe334e5DEB8522cD85097b47a69afC939715FFA"]]
        #else
        var address = coinInfo.address
        let assetList = await coinInfo.coin.getSimpleAssetList(addr: address)
        #endif
        
        logger.info("fetchTokenList: \(assetList)")
        
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
                        var nftMerged = nft.merging(asset, uniquingKeysWith: { (first, _) in first })
                        nftMerged["type"] = "nft"
                        nftList.append(nftMerged)
                        print("NfcReader: added nftMerged: \(nftMerged)")
                    }
                } else { // token
                    var assetCopy = asset
                    assetCopy["type"] = "token"
                    
                    // get price if available
                    if let tokenBalance = coinInfo.getTokenBalanceDouble(tokenData: asset),
                        let tokenExchangeRate = Double(asset["tokenExchangeRate"] ?? ""),
                        let currencyForExchangeRate = asset["currencyForExchangeRate"] {
                        
                        print("in fetchDataFromWeb [\(index)] tokenBalance: \(tokenBalance)")
                        print("in fetchDataFromWeb [\(index)] tokenExchangeRate: \(tokenExchangeRate)")
                        print("in fetchDataFromWeb [\(index)] currencyForExchangeRate: \(currencyForExchangeRate)")
                        
                        // selectedFirstCurrency
                        // TODO: cache result?
                        if let currencyExchangeRate1 = await coinInfo.coin.getExchangeRateBetween(coin: currencyForExchangeRate, otherCoin: selectedFirstCurrency)
                        {
                            print("in fetchDataFromWeb [\(index)] currencyExchangeRate1: \(currencyExchangeRate1)")
                            print("in fetchDataFromWeb [\(index)] selectedFirstCurrency: \(selectedFirstCurrency)")
                            
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
                    }
                    
                    tokenList.append(assetCopy)
                    print("NfcReader: added assetCopy: \(assetCopy)")
                } // if nft else token
            } // if contract
        } // for asset

        print("NfcReader: tokenList: \(tokenList)")
        print("NfcReader: nftList: \(nftList)")
        
        let result = AssetsResult(
            nftList: nftList,
            tokenList: tokenList)
        
        return result
    }
}
