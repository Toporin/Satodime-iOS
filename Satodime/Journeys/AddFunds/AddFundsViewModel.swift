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
    @Published var headerImageName: String = ""
    
    let indexPosition: Int
    private var vault: VaultItem

    // MARK: - Literals
    let viewTitle = "addFunds"
    let title: String = "depositAddress"
    let subtitle: String = "youOrAnybodyCanDepositFunds"
    
    init(indexPosition: Int, vault: VaultItem) {
        self.indexPosition = indexPosition
        self.vault = vault
        super.init()
        self.slotNumber = "0\(indexPosition+1)"
        self.pubAddressToDisplay = vault.address
        self.coinIcon = "ic_\(vault.getCoinSymbol().lowercased())"
        self.headerImageName = self.vault.isSealed() ? "bg_header_addfunds" : "bg_red_gradient"
    }

    func copyToClipboard() {
        UIPasteboard.general.string = self.pubAddressToDisplay
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        generator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.impactOccurred()
        }
    }
    
    func getSealStatus() -> SealStatus {
        return self.vault.isSealed() ? .sealed : .unsealed
    }
}

