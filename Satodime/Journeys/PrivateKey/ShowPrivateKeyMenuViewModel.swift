//
//  ShowPrivateKeyMenuViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation

enum ShowPrivateKeyMode: String, Hashable {
    case legacy = "Show private key (Legacy)"
    case wif = "Show private key (WIF)"
    case entropy = "Show entropy"
}

final class ShowPrivateKeyMenuViewModel: BaseViewModel {
    // MARK: - Properties
    let cardService: PCardService
    
    @Published var vaultCardViewModel: VaultCardViewModel
    @Published var selectedMode: ShowPrivateKeyMode = .legacy
    @Published var keyResult: PrivateKeyResult?
    @Published var isBottomSheetPresented = false
    let indexPosition: Int
    let keyDisplayOptions: [ShowPrivateKeyMode] = [.legacy, .wif, .entropy]
    
    // MARK: - Literals
    let title = "Show private key"
    
    init(cardService: PCardService, vaultCardViewModel: VaultCardViewModel, indexPosition: Int) {
        self.cardService = cardService
        self.vaultCardViewModel = vaultCardViewModel
        self.indexPosition = indexPosition
    }
    
    func showKey(mode: ShowPrivateKeyMode) {
        cardService.getPrivateKey(vaultIndex: indexPosition, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .getPrivate(let item):
                DispatchQueue.main.async {
                    self.keyResult = item
                    self.selectedMode = mode
                    self.isBottomSheetPresented = true
                }
            default:
                break
            }
        })
    }
}
