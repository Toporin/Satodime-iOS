//
//  VaultSetupSelectChainViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 28/09/2023.
//

import Foundation
import SwiftUI

final class VaultSetupSelectChainViewModel: ObservableObject {
    // MARK: - Properties
    @Published var selectedCrypto: CryptoCurrency? = nil
    @Published var isNextViewActive = false
    
    // MARK: - Literals
    let title = "Select the blockchain"
    let subtitle = "Select the cryptocurrency you want to store."
}
