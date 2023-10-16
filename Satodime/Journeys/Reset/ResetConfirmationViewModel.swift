//
//  ResetConfirmationViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation

final class ResetConfirmationViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var vaultCardViewModel: VaultCardViewModel
    let indexPosition: Int
    
    // MARK: - Literals
    let title = "**Congrats!**"
    let subtitle = "Vault successfully RESET"
    
    let confirmationText = "You can now **CREATE** & **SEAL** a new **vault**."
        
    let continueButtonTitle = "Back to my vaults"
    
    init(vaultCardViewModel: VaultCardViewModel, indexPosition: Int) {
        self.vaultCardViewModel = vaultCardViewModel
        self.indexPosition = indexPosition
    }
    
    func completeFlow() {
        self.navigateTo(destination: .goBackHome)
    }
}
