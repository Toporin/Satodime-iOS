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
    let title = "Congrats!"
    let subtitle = "Your vault has been successfully created and sealed."
    let informationText = "Remember that your **private keys** will be accessible once you’ve **unsealed** your **vault**."
    let continueButtonTitle = "Show my vault"
    
    init(selectedCrypto: CryptoCurrency) {
        self.selectedCrypto = selectedCrypto
    }
}
