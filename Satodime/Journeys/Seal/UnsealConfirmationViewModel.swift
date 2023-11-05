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
    let title = "Congrats!"
    let subtitle = "**Vault** successfully **UNSEAL**"
    
    let confirmationText = "You can now view the corresponding private key and import it into another wallet."
        
    let continueButtonTitle = "Show the private key"
    
    init(vaultCardViewModel: VaultCardViewModel, indexPosition: Int) {
        self.vaultCardViewModel = vaultCardViewModel
        self.indexPosition = indexPosition
    }
    
    func completeFlow() {
        self.navigateTo(destination: .privateKey)
    }
}
