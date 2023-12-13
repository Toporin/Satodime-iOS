//
//  VaultSetupSelectChainViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 28/09/2023.
//

import Foundation
import SwiftUI

final class VaultSetupSelectChainViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var selectedCrypto: CryptoCurrency? = nil
    @Published var isNextViewActive = false
    var index: Int
    var vaultCards: VaultsList
    
    // MARK: - Literals
    let title = "selectTheBlockchain"
    let subtitle = "selectTheCrypto"
    
    init(index: Int, vaultCards: VaultsList) {
        self.index = index
        self.vaultCards = vaultCards
    }
}
