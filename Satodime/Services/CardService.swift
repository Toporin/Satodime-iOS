//
//  CardService.swift
//  Satodime
//
//  Created by Lionel Delvaux on 05/10/2023.
//

enum CardAction {
    case accept
    case getPrivate
    case reset
    case seal
    case transfer
    case unseal
}

protocol PCardService {
    func getCardStatus()
}

import Foundation

class CardService: PCardService {
    func getCardStatus() {
        
    }
}
