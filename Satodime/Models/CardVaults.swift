//
//  CardVaults.swift
//  Satodime
//
//  Created by Lionel Delvaux on 15/10/2023.
//

import Foundation

class CardVaults {
    var isOwner: Bool
    let isCardAuthentic: Bool
    let cardVersion: String
    let vaults: [VaultItem]
    var cardAuthenticity: CardAuthenticity?
    
    init(isOwner: Bool, isCardAuthentic: Bool, cardVersion: String, vaults: [VaultItem], cardAuthenticity: CardAuthenticity? = nil) {
        self.isOwner = isOwner
        self.isCardAuthentic = isCardAuthentic
        self.cardVersion = cardVersion
        self.vaults = vaults
        self.cardAuthenticity = cardAuthenticity
    }
}
