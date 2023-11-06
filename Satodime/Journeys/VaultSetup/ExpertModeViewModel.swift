//
//  ExpertModeViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 16/10/2023.
//

import Foundation
import SwiftUI
import CryptoSwift

enum NetworkMode: String, CaseIterable, SelectableItem {
    case mainNet = "MainNet"
    case testNet = "TestNet"

    var displayString: String {
        return self.rawValue
    }
}

final class ExpertModeViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var selectedCrypto: CryptoCurrency
    @Published var selectedNetwork: NetworkMode = .mainNet
    @Published var entropy: String = ""
    @Published var isNextViewActive = false
    @Published var vaultCards: VaultsList
    
    let cardService: PCardService
    var index: Int
    
    // MARK: - Literals
    let title = "expertMode"
    let informationText = "theExpertModeAllowsYou"
    
    let networkChoiceSystem = "network"
    let mainNetText = "mainNet"
    let testNetText = "testNet"
    
    let entropyTitle = "entropy"
    
    let continueButtonTitle = String(localized: "createAndSeal")
    
    // MARK: - Lifecycle
    init(cardService: PCardService, selectedCrypto: CryptoCurrency, index: Int, vaultCards: VaultsList) {
        self.cardService = cardService
        self.selectedCrypto = selectedCrypto
        self.index = index
        self.vaultCards = vaultCards
    }
    
    func sealSlot() {
        print("Will create for index : \(self.index)")
        self.cardService.sealVault(vaultIndex: self.index, for: self.selectedCrypto, useTestNet: self.isTestnet(), contractBytes: [UInt8](), tokenidBytes: [UInt8](), entropyBytes: self.extractEntropy(randomString: self.entropy), completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .sealed(let result):
                DispatchQueue.main.async {
                    let vaultCardViewModel = VaultCardViewModel(walletAddress: result.vaultItem.address, vaultItem: result.vaultItem, coinService: CoinService(), isTestnet: result.vaultItem.coin.isTestnet)
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
    
    private func isTestnet() -> Bool {
        return self.selectedNetwork == .testNet
    }
    
    private func extractEntropy(randomString: String) -> [UInt8] {
        var randomBytes = Array(randomString.utf8)
        if (randomBytes.count>32){
            randomBytes = Digest.sha256(randomBytes)
        } else if randomBytes.count<32 {
            randomBytes = randomBytes + [UInt8](repeating: 0, count: 32-randomBytes.count)
        }
        return randomBytes
    }
}
