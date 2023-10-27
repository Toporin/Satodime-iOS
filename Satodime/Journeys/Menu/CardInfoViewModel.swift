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
    
    // MARK: - Literals
    let title = "Card info"
    let ownerTitle = "Card ownership status"
    let ownerText = "You are the card owner"
    let notOwnerText = "You are not the card owner"
    
    let cardVersionTitle = "Card version"
    
    let cardGenuineTitle = "Card authenticity"
    let cardGenuineText = "This card is genuine"
    let cardNotGenuineText = "This card is not genuine"
    
    let certButtonTitle = "Certificates details"
    
    init(cardVaults: CardVaults) {
        self.cardVaults = cardVaults
    }
    
    func onCertButtonTapped() {
        guard let authenticity = self.cardVaults.cardAuthenticity else { return }
        self.isCertDetailsViewActive = true
    }
}
