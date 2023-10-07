//
//  ActionData.swift
//  Satodime for iOS
//
//  Created by Satochip on 30/01/2023.
//  Copyright © 2023 Satochip S.R.L.
//

import Foundation

public struct ActionParams {
    
    public static let assetDict: [String : UInt8] =
    ["Undefined": 0x00,
     "Coin" : 0x01,
     "Token": 0x10,
     "ERC20": 0x11,
     "BEP20": 0x12,
     "NFT": 0x40,
     "ERC721": 0x41,
     "BEP721": 0x42,
     "Other": 0xFF,]
    
    public static let coinDict: [String : UInt32] =
    ["BTC": 0x80000000,
     "LTC": 0x80000002,
     "XCP": 0x80000009,
     "ETH": 0x8000003c,
     "BCH": 0x80000091,
     "BSC": 0x8000232e,
    ]
    
    var index: UInt8 = 0xFF
    var action: String = ""
    
    // seal params
    var coinString: String = ""
    var assetString = ""
    var useTestnet = true
    var contractBytes = [UInt8]()
    var tokenidBytes = [UInt8]()
    var entropyBytes = [UInt8]()
    
    init(index: UInt8, action: String){
        self.index = index
        self.action = action
    }
    
    init(index: UInt8, action: String, coin: String, asset: String, useTestnet: Bool, contractBytes: [UInt8], tokenidBytes: [UInt8], entropyBytes: [UInt8]){
        self.index = index
        self.action = action
        self.coinString = coin
        self.assetString = asset
        self.useTestnet = useTestnet
        self.contractBytes = contractBytes
        self.tokenidBytes = tokenidBytes
        self.entropyBytes = entropyBytes
    }
    
    public func getSlip44() -> UInt32{
        var slip44 = ActionParams.coinDict[coinString] ?? 0xffffffff
        if useTestnet {
            slip44 = (slip44 & 0x7fffffff)
        }
        return slip44
    }
    
    public func getAssetByte() -> UInt8 {
        return ActionParams.assetDict[assetString] ?? 0x01
    }
}
    
    
    
