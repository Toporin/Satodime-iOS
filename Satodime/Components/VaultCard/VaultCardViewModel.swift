//
//  VaultCardViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 17/10/2023.
//

import Foundation
import SwiftUI
import Combine

class EmptyVaultViewModel: Hashable {
    var vaultItem: VaultItem
    
    init(vaultItem: VaultItem) {
        self.vaultItem = vaultItem
    }
    
    static func == (lhs: EmptyVaultViewModel, rhs: EmptyVaultViewModel) -> Bool {
        return true
    }

    func hash(into hasher: inout Hasher) {

    }
}

class VaultCardViewModel: ObservableObject, Hashable {
    let coinService: PCoinService
    let walletAddress: String
    let isTestnet: Bool

    @Published var vaultItem: VaultItem {
        didSet {
            updateProperties(with: vaultItem)
        }
    }

    @Published var indexId: Int {
        didSet {
            self.positionText = "0\(indexId+1)"
        }
    }
    
    @Published var positionText: String
    @Published var addressText: String
    @Published var sealStatus: SealStatus
    @Published var imageName: String
    @Published var balanceTitle: String
    @Published var fiatBalance: String
    @Published var cryptoBalance: String
    @Published var tokenList: [[String:String]] = []
    @Published var nftList: [[String:String]] = []
    @Published var cardBackground: String
    
    func sealedBackgroundImageName() -> String {
        if indexId == 1 {
            return "bg_vault_card_2"
        }
        if indexId == 2 {
            return "bg_vault_card_3"
        }
        return "bg_vault_card"
    
    }

    init(walletAddress: String, vaultItem: VaultItem, coinService: PCoinService, isTestnet: Bool) {
        self.coinService = coinService
        self.walletAddress = walletAddress
        self.vaultItem = vaultItem
        self.isTestnet = isTestnet
        self.indexId = 0
        self.positionText = "00"
        self.addressText = ""
        self.sealStatus = .unsealed
        self.imageName = ""
        self.balanceTitle = ""
        self.fiatBalance = ""
        self.cryptoBalance = ""
        self.cardBackground = "bg_vault_card"

        updateProperties(with: vaultItem)
    }

    static func == (lhs: VaultCardViewModel, rhs: VaultCardViewModel) -> Bool {
        return lhs.walletAddress == rhs.walletAddress
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(walletAddress)
    }
    
    func setIndexId(index: Int) {
        self.indexId = index
        self.cardBackground = self.vaultItem.isSealed() ? self.sealedBackgroundImageName() : "bg_card_unsealed"
    }

    private func updateProperties(with vaultItem: VaultItem) {
        self.addressText = vaultItem.address
        self.sealStatus = vaultItem.isSealed() ? .sealed : .unsealed
        self.imageName = "ic_\(vaultItem.getCoinSymbol().lowercased())"
        self.balanceTitle = "Total balance"
        self.fiatBalance = "0"
        self.cardBackground = vaultItem.isSealed() ? self.sealedBackgroundImageName() : "bg_card_unsealed"
        
        Task {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 7
            
            let fetchedCryptoBalance = await self.coinService.fetchCryptoBalance(for: vaultItem)
            DispatchQueue.main.async {
                if let formattedAmount = numberFormatter.string(from: NSNumber(value: fetchedCryptoBalance)) {
                    self.cryptoBalance = "\(formattedAmount) \(vaultItem.coin.coinSymbol)"
                } else {
                    self.cryptoBalance = "\(fetchedCryptoBalance) \(vaultItem.coin.coinSymbol)"
                }
            }
            
            let fetchedFiatBalance = await self.coinService.fetchFiatBalance(for: vaultItem, with: fetchedCryptoBalance)
            DispatchQueue.main.async {
                self.fiatBalance = fetchedFiatBalance
            }
        }
    }
}

enum VaultCardViewModelType: Hashable {
    case vaultCard(VaultCardViewModel)
    case emptyVault(EmptyVaultViewModel)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .vaultCard(let viewModel):
            hasher.combine(0)
            hasher.combine(viewModel)
        case .emptyVault(let viewModel):
            hasher.combine(1)
            hasher.combine(viewModel)
        }
    }
    
    static func == (lhs: VaultCardViewModelType, rhs: VaultCardViewModelType) -> Bool {
        switch (lhs, rhs) {
        case (.vaultCard(let leftViewModel), .vaultCard(let rightViewModel)):
            return leftViewModel == rightViewModel
        case (.emptyVault(let leftViewModel), .emptyVault(let rightViewModel)):
            return leftViewModel == rightViewModel
        default:
            return false
        }
    }
}
