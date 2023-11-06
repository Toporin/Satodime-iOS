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
    let title = "warning"
    let subtitle = "youAreAboutToReset"
    
    let resetText = "resettingThisCryptoVaultWill"
    
    let informationText = "afterThatYouWillBeAbleTo"
    
    let confirmationText = "iConfirmThatBackup"
    
    let continueButtonTitle = String(localized: "resetTheVault")

    
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
