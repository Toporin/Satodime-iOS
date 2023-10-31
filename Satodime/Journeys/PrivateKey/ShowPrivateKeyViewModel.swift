//
//  ShowPrivateKeyViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 30/10/2023.
//

import Foundation
import UIKit

final class ShowPrivateKeyViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var keyToDisplay: String = ""
    @Published var titleMode: String = ""
    @Published var subtitleMode: String = ""
    @Published var slotNumber: String = ""
    @Published var coinIcon: String = ""
    
    var mode: ShowPrivateKeyMode
    var keyResult: PrivateKeyResult?
    private var vault: VaultItem

    // MARK: - Literals
    let title = "Show private key"
    
    init(mode: ShowPrivateKeyMode, keyResult: PrivateKeyResult?, vault: VaultItem) {
        self.mode = mode
        self.keyResult = keyResult
        self.vault = vault
        super.init()
        self.slotNumber = "0\(vault.index)"
        self.coinIcon = "ic_\(vault.getCoinSymbol().lowercased())"
        self.determineKeyToDisplay()
    }

    func determineKeyToDisplay() {
        guard let keyResult = self.keyResult else { return }
        
        self.vault.privkey = keyResult.privkey
        self.vault.entropy = keyResult.entropy
        
        switch mode {
        case .legacy:
            self.titleMode = "Private key"
            self.subtitleMode = "(Legacy)"
            self.keyToDisplay = vault.getPrivateKeyString()
        case .wif:
            self.titleMode = "Private key"
            self.subtitleMode = "(Wallet Import Format)"
            self.keyToDisplay = vault.getWifString()
        case .entropy:
            self.titleMode = "Entropy"
            self.subtitleMode = ""
            self.keyToDisplay = vault.getEntropyString()
        }
    }

    func copyToClipboard() {
        UIPasteboard.general.string = self.keyToDisplay
    }
}
