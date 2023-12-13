//
//  textFormatUtil.swift
//  Satodime
//
//  Created by Satochip on 09/12/2023.
//

import Foundation

extension Array where Element == UInt8 {
    var bytesToHex: String {
        var hexString: String = ""
        var count = self.count
        for byte in self
        {
            hexString.append(String(format:"%02X", byte))
            count = count - 1
        }
        return hexString
    }
}

class SatodimeUtil {
    
    static func getNftImageUrlString(link: String) -> String {
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
        } else {
            // do nothing
            return nftImageUrlString
        }
        LoggerService.shared.debug("Converted link: \(link) to: \(nftImageUrlString)", tag: "SatodimeUtil.getNftImageUrlString")
        return nftImageUrlString
    }
    
    static func getBalanceDouble(balanceString: String?, decimalsString: String?) -> Double? {
        
        if let balanceString = balanceString {
            let decimalsString = decimalsString ?? "0"
            
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
    
    static func formatBalance(balanceString: String?, decimalsString: String?, symbol: String?, maxFractionDigit: Int = 8) -> String {
        let symbol = symbol ?? ""
        
        if let balanceDouble = getBalanceDouble(balanceString: balanceString, decimalsString: decimalsString) {
            return formatBalance(balanceDouble: balanceDouble, symbol: symbol, maxFractionDigit: maxFractionDigit)
        } else {
            return "? " + symbol
        }
    }
    
    static func formatBalance(balanceDouble: Double?, symbol: String?, maxFractionDigit: Int = 8) -> String {
        
        let symbol = symbol ?? ""
        
        if let balanceDouble {

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = maxFractionDigit // number of fraction digits shown
            
            let balanceFormatted = numberFormatter.string(from: NSNumber(value: balanceDouble)) ?? "?"
            let balanceDisplay = balanceFormatted + " " + symbol
            return balanceDisplay
        } else {
            return "? " + symbol
        }
    }
    
}

