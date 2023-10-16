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
    let title = "Warning"
    let subtitle = "You are about to UNSEAL the following crypto vault."
    
    let unsealText = "**Unsealing** this crypto vault will reveal the corresponding private key."
    let transferText = "You can then transfer the entire balance to another wallet using the revealed private key."
    
    let informationText = "This action is irreversible."
    
    let continueButtonTitle = "UNSEAL"

    
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
