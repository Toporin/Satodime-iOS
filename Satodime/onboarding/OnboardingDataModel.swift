//
//  OnboardingModel.swift
//  Onboarding
//
//  Created by Augustinas Malinauskas on 06/07/2020.
//  Copyright © 2020 Augustinas Malinauskas. All rights reserved.
//

import Foundation
import SwiftUI

struct OnboardingDataModel {
    var image: String
    var heading: String
    var text: String
}

extension OnboardingDataModel {
    static var data: [OnboardingDataModel] = [
        OnboardingDataModel(image: "onboarding-intro1", heading: String(localized: "Welcome!"), text: String(localized: "Satodime allows you to easily create cryptocurrency vaults on the fly.\n\nIt supports the most innovative cryptocurrencies and ERC-20 tokens.")),
        OnboardingDataModel(image: "onboarding-intro2", heading: String(localized: "Use it indefinitely"), text: String(localized: "Create upt to 3 vaults to store your favorite cryptocurrencies and NFTs. \n\nSeal a new vault, load your token. Unseal it to recover the private key. And reuse it indefinitely!")),
        OnboardingDataModel(image: "onboarding-nfc", heading: String(localized: "How to use NFC"), text: String(localized: "Your Satodime comes with built-in interface. \n\nTo interact with the card, you need to put it on your NFC reader and keep it on throughout the operation.")),
        OnboardingDataModel(image: "onboarding-example", heading: String(localized: "A sample vault"), text: String(localized: "A green color means the vault is sealed: the private key has been generated randomly by the card and never been exposed to anyone. An orange vault means the vault has been unsealed. A grey vault means the private key has not been generated yet. \n\nYou can click on the icon on the upper-right of the vault to change the vault status (seal, unseal or reset the vault). \n\nYou can click on the arrow on the lower-right to get more information.")),
    ]
}
