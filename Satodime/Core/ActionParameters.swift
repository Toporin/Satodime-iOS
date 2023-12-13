//
//  ActionParameters.swift
//  Satodime for iOS
//
//  Created by Satochip on 06/12/2023.
//  Copyright © 2023 Satochip S.R.L.
//

import Foundation

public enum ActionType: String {
    case scanCard
    case releaseOwnership
    case takeOwnership
    case sealVault
    case unsealVault
    case resetVault
    case getPrivateInfo
}

public enum CoinType: UInt32 {
    case btc = 0x80000000
    case ltc = 0x80000002
    case xcp = 0x80000009
    case eth = 0x8000003c
    case bch = 0x80000091
    case bsc = 0x8000232e
}

public struct ActionParameters {
    
//    public static let assetDict: [String : UInt8] =
//    ["Undefined": 0x00,
//     "Coin" : 0x01,
//     "Token": 0x10,
//     "ERC20": 0x11,
//     "BEP20": 0x12,
//     "NFT": 0x40,
//     "ERC721": 0x41,
//     "BEP721": 0x42,
//     "Other": 0xFF,]
    
    public static let coinDict: [String : UInt32] =
    ["BTC": 0x80000000,
     "LTC": 0x80000002,
     "XCP": 0x80000009,
     "ETH": 0x8000003c,
     "BCH": 0x80000091,
     "BSC": 0x8000232e,
    ]
    
    var index: UInt8 = 0xFF
    var action: ActionType = .scanCard
    
    // seal params
    //var coinString: String = ""
    var coinType: CoinType = .btc
//    var assetString = ""
    var useTestnet = true
//    var contractBytes = [UInt8]()
//    var tokenidBytes = [UInt8]()
    var entropyBytes = [UInt8]()
    
    init(index: UInt8, action: ActionType){
        self.index = index
        self.action = action
    }
    
    init(index: UInt8, action: ActionType, coinType: CoinType, useTestnet: Bool, entropyBytes: [UInt8]){
        self.index = index
        self.action = action
        //self.coinString = coinString
        self.coinType = coinType
//        self.assetString = assetString
        self.useTestnet = useTestnet
//        self.contractBytes = contractBytes
//        self.tokenidBytes = tokenidBytes
        self.entropyBytes = entropyBytes
    }
    
    public func getSlip44() -> UInt32{
        var slip44 = coinType.rawValue //ActionParams.coinDict[coinString] ?? 0xffffffff
        if useTestnet {
            slip44 = (slip44 & 0x7fffffff)
        }
        return slip44
    }
    
//    public func getAssetByte() -> UInt8 {
//        return ActionParams.assetDict[assetString] ?? 0x01
//    }
}
    
    
    
