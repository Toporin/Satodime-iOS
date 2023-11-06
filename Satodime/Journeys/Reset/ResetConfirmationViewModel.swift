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
    let title = "**\(String(localized: "congrats"))**"
    let subtitle = "vaultSuccessfullyReset"
    
    let confirmationText = "youCanNowCreateAndSeal"
        
    let continueButtonTitle = String(localized: "backToMyVaults")
    
    init(vaultCardViewModel: VaultCardViewModel, indexPosition: Int) {
        self.vaultCardViewModel = vaultCardViewModel
        self.indexPosition = indexPosition
    }
    
    func completeFlow() {
        self.navigateTo(destination: .goBackHome)
    }
}
