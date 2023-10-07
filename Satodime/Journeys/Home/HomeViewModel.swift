//
//  HomeViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI

class EmptyVaultViewModel: Hashable {
    static func == (lhs: EmptyVaultViewModel, rhs: EmptyVaultViewModel) -> Bool {
        return true
    }

    func hash(into hasher: inout Hasher) {

    }
}


class VaultCardViewModel: ObservableObject, Hashable {
    @Published var title: String
    @Published var addressText: String
    @Published var sealStatus: SealStatus
    @Published var imageName: String
    @Published var balanceTitle: String
    @Published var balanceAmount: String
    @Published var balanceCurrency: String

    init(
        title: String,
        addressText: String,
        sealStatus: SealStatus,
        imageName: String,
        balanceTitle: String,
        balanceAmount: String,
        balanceCurrency: String
    ) {
        self.title = title
        self.addressText = addressText
        self.sealStatus = sealStatus
        self.imageName = imageName
        self.balanceTitle = balanceTitle
        self.balanceAmount = balanceAmount
        self.balanceCurrency = balanceCurrency
    }
    
    static func == (lhs: VaultCardViewModel, rhs: VaultCardViewModel) -> Bool {
        return lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

enum VaultCardViewModelType: Hashable {
    case vaultCard(VaultCardViewModel)
    case emptyVault(EmptyVaultViewModel)
    
    // Implement Hashable conformance
    func hash(into hasher: inout Hasher) {
        switch self {
        case .vaultCard(let viewModel):
            hasher.combine(0) // You can use a unique integer for each case
            hasher.combine(viewModel)
        case .emptyVault(let viewModel):
            hasher.combine(1) // Use a different integer for each case
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



final class HomeViewModel: ObservableObject {
    // MARK: - Properties
    @Published var vaultCards: [VaultCardViewModelType] = []
    
    // MARK: - Literals
    let viewTitle: String = "Vaults"
    
    init() {
        vaultCards = [
                    .vaultCard(VaultCardViewModel(
                        title: "1",
                        addressText: "0x1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa",
                        sealStatus: .sealed,
                        imageName: "ic_eth",
                        balanceTitle: "Balance",
                        balanceAmount: "1,234.56 $",
                        balanceCurrency: "1.2 ETH"
                    )),
                    .emptyVault(EmptyVaultViewModel()),
                    .emptyVault(EmptyVaultViewModel())
                ]
    }
}
