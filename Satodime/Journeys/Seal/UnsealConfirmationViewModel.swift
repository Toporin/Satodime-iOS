//
//  UnsealConfirmationViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation

final class UnsealConfirmationViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var vaultCardViewModel: VaultCardViewModel
    let indexPosition: Int
    
    // MARK: - Literals
    let title = "congrats"
    let subtitle = "vaultSuccessfullyUnseal"
    
    let confirmationText = "youCanNowViewThePrivateKey"
        
    let continueButtonTitle = String(localized: "showThePrivateKey")
    
    init(vaultCardViewModel: VaultCardViewModel, indexPosition: Int) {
        self.vaultCardViewModel = vaultCardViewModel
        self.indexPosition = indexPosition
    }
    
    func completeFlow() {
        self.navigateTo(destination: .privateKey)
    }
}
