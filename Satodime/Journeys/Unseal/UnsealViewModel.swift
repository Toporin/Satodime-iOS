//
//  UnsealViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation

final class UnsealViewModel: BaseViewModel {
    // MARK: - Properties
    let cardService: PCardService
    
    @Published var vaultCardViewModel: VaultCardViewModel
    @Published var pushConfirmationView: Bool = false
    
    let indexPosition: Int
    
    // MARK: - Literals
    let title = "warning"
    let subtitle = "youAreAboutToUnseal"
    
    let unsealText = "unsealingThisCryptoVaultWillReveal"
    let transferText = "youCanThenTransferTheEntireBalance"
    
    let informationText = "thisActionIsIrreversible"
    
    let continueButtonTitle = String(localized: "unseal")

    init(cardService: PCardService, vaultCardViewModel: VaultCardViewModel, indexPosition: Int) {
        self.cardService = cardService
        self.vaultCardViewModel = vaultCardViewModel
        self.indexPosition = indexPosition
    }
    
    func unsealSlot() {
        self.cardService.unseal(vaultIndex: self.indexPosition, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .unsealed(let status):
                DispatchQueue.main.async {
                    self.vaultCardViewModel.vaultItem.keyslotStatus.status = status
                }
                self.pushConfirmationView = true
            default:
                break
            }
        })
    }
}
