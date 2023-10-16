//
//  ResetViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation

final class ResetViewModel: BaseViewModel {
    // MARK: - Properties
    let cardService: PCardService
    
    @Published var vaultCardViewModel: VaultCardViewModel
    @Published var pushConfirmationView: Bool = false
    @Published var hasUserConfirmedTerms = false
    var vaultCards: VaultsList
    
    let indexPosition: Int
    
    // MARK: - Literals
    let title = "Warning"
    let subtitle = "You are about to RESET the following crypto vault."
    
    let resetText = "**Reset** this **vault** will completely and irrevocably **delete** the corresponding **private keys** from your **Satodime device**."
    
    let informationText = "After that you will be able to **create a new crypto vault**."
    
    let confirmationText = "I confirm that I have made a backup of the corresponding private key."
    
    let continueButtonTitle = "Reset the vault"

    
    init(cardService: PCardService, vaultCardViewModel: VaultCardViewModel, indexPosition: Int, vaultsList: VaultsList) {
        self.cardService = cardService
        self.vaultCardViewModel = vaultCardViewModel
        self.indexPosition = indexPosition
        self.vaultCards = vaultsList
    }
    
    func reset() {
        self.cardService.reset(vaultIndex: self.indexPosition, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .reset(let updatedItem):
                DispatchQueue.main.async {
                    let vaultCardViewModel = EmptyVaultViewModel(vaultItem: updatedItem)
                    self.vaultCards.items[self.indexPosition] = .emptyVault(vaultCardViewModel)
                }
                self.pushConfirmationView = true
            default:
                break
            }
        })
    }
}
