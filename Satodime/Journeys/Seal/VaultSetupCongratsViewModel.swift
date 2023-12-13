//
//  VaultSetupCongratsViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 02/10/2023.
//

import Foundation
import SwiftUI

final class VaultSetupCongratsViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var selectedCrypto: CryptoCurrency
    @Published var isNextViewActive = false
    
    // MARK: - Literals
    let title = "congrats"
    let subtitle = "yourVaultsHasBeenCreated"
    let informationText = "rememberPrivateKeys"
    let continueButtonTitle = String(localized: "showMyVault")
    
    init(selectedCrypto: CryptoCurrency) {
        self.selectedCrypto = selectedCrypto
    }
}
