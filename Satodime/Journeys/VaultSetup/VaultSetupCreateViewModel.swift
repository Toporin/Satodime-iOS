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
    let title = "createYourVault"
    let subtitle = "youAreAboutToCreateAndSeal"
    let informationText = "onceTheVaultHasBeengenerated"
    let activateExpertModeText = String(localized: "activateTheExpertMode")
    let continueButtonTitle = String(localized: "createAndSeal")
    
    init(cardService: PCardService, selectedCrypto: CryptoCurrency, index: Int, vaultCards: VaultsList) {
        self.cardService = cardService
        self.selectedCrypto = selectedCrypto
        self.index = index
        self.vaultCards = vaultCards
    }
    
    func goToExpertMode() {
        self.isExpertModeViewActive = true
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
                    let vaultCardViewModel = VaultCardViewModel(walletAddress: result.vaultItem.address, vaultItem: result.vaultItem, coinService: CoinService(), isTestnet: result.vaultItem.coin.isTestnet, addressWebLink: result.vaultItem.coin.getAddressWebLink(address: result.vaultItem.address))
                    if(self.vaultCards.items.isEmpty) {
                        self.vaultCards.items.append(.vaultCard(vaultCardViewModel))
                    } else {
                        let bufferVaultCards = self.vaultCards
                        bufferVaultCards.guid = UUID().uuidString
                        bufferVaultCards.items[self.index] = .vaultCard(vaultCardViewModel)
                        self.vaultCards = bufferVaultCards
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
