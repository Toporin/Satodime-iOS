//
//  VaultSetupCreateViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 02/10/2023.
//

import Foundation
import SwiftUI

final class VaultSetupCreateViewModel: ObservableObject {
    // MARK: - Properties
    @Published var selectedCrypto: CryptoCurrency
    @Published var isExpertModeActivated = false
    @Published var isNextViewActive = false
    
    // MARK: - Literals
    let title = "Create your vault"
    let subtitle = "You are about to create and seal a vault. A new key pair will be generated automatically."
    let informationText = "Once the **vault** has been generated, the corresponding **private** **key** is hidden in the **Satodime** **chip’s** **memory**."
    let activateExpertModeText = "Activate the expert mode"
    let continueButtonTitle = "Create and Seal"
    
    init(selectedCrypto: CryptoCurrency) {
        self.selectedCrypto = selectedCrypto
    }
}
