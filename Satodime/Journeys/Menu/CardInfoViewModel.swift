//
//  CardInfoViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation

final class CardInfoViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var cardVaults: CardVaults
    @Published var isCertDetailsViewActive = false
    @Published var shouldShowAuthenticityScreen = false
    
    // MARK: - Literals
    let title = "cardInfo"
    let ownerTitle = "cardOwnershipStatus"
    let ownerText = "youAreTheCardOwner"
    let notOwnerText = "youAreNotTheCardOwner"
    
    let cardVersionTitle = "cardVersion"
    
    let cardGenuineTitle = "cardAuthenticity"
    let cardGenuineText = "thisCardIsGenuine"
    let cardNotGenuineText = "thisCardIsNotGenuine"
    
    let certButtonTitle = "certDetails"
    
    init(cardVaults: CardVaults) {
        self.cardVaults = cardVaults
    }
    
    func onCertButtonTapped() {
        guard let authenticity = self.cardVaults.cardAuthenticity else { return }
        self.isCertDetailsViewActive = true
    }
    
    func gotoAuthenticityScreen() {
        self.shouldShowAuthenticityScreen = true
    }
}
