//
//  AddFundsViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 02/11/2023.
//

import Foundation
import UIKit

final class AddFundsViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var pubAddressToDisplay: String = ""
    @Published var slotNumber: String = ""
    @Published var coinIcon: String = ""
    
    let indexPosition: Int
    private var vault: VaultItem

    // MARK: - Literals
    let viewTitle = "Add funds"
    let title: String = "Deposit address"
    let subtitle: String = "You or anybody can deposit funds to this vault by sending crypto tokens to this address."
    
    init(indexPosition: Int, vault: VaultItem) {
        self.indexPosition = indexPosition
        self.vault = vault
        super.init()
        self.slotNumber = "0\(indexPosition+1)"
        self.pubAddressToDisplay = vault.address
        self.coinIcon = "ic_\(vault.getCoinSymbol().lowercased())"
    }

    func copyToClipboard() {
        UIPasteboard.general.string = self.pubAddressToDisplay
    }
    
    func getSealStatus() -> SealStatus {
        return self.vault.isSealed() ? .sealed : .unsealed
    }
}

