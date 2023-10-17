//
//  VaultSetupCreateViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 02/10/2023.
//

import Foundation
import SwiftUI

final class VaultSetupCreateViewModel: BaseViewModel {
    // MARK: - Properties
    let cardService: PCardService
    @Published var selectedCrypto: CryptoCurrency
    @Published var isExpertModeActivated = false
    @Published var isNextViewActive = false
    @Published var isExpertModeViewActive = false
    @Published var vaultCards: VaultsList
    var index: Int
    
    // MARK: - Literals
    let title = "Create your vault"
    let subtitle = "You are about to create and seal a vault. A new key pair will be generated automatically."
    let informationText = "Once the **vault** has been generated,\nthe corresponding **private** **key** is\nhidden in the **Satodime** **chip’s** **memory**."
    let activateExpertModeText = "Activate the expert mode"
    let continueButtonTitle = "Create and Seal"
    
    init(cardService: PCardService, selectedCrypto: CryptoCurrency, index: Int, vaultCards: VaultsList) {
        self.cardService = cardService
        self.selectedCrypto = selectedCrypto
        self.index = index
        self.vaultCards = vaultCards
    }
    
    func sealSlot() {
        guard !self.isExpertModeActivated else {
            self.isExpertModeViewActive = true
            return
        }
        
        print("Will create for index : \(self.index)")
        self.cardService.sealVault(vaultIndex: self.index, for: self.selectedCrypto, useTestNet: false, contractBytes: [UInt8](), tokenidBytes: [UInt8](), entropyBytes: [UInt8](), completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .sealed(let result):
                DispatchQueue.main.async {
                    let vaultCardViewModel = VaultCardViewModel(walletAddress: result.vaultItem.address, vaultItem: result.vaultItem, coinService: CoinService())
                    if(self.vaultCards.items.isEmpty) {
                        self.vaultCards.items.append(.vaultCard(vaultCardViewModel))
                    } else {
                        self.vaultCards.items[self.index] = .vaultCard(vaultCardViewModel)
                    }
                    self.isNextViewActive = true
                    print("Sealed!")
                }
            default:
                break
            }
        })
    }
    
}
