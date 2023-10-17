//
//  HomeViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI
import Combine

class VaultsList: ObservableObject {
    @Published var items: [VaultCardViewModelType]

    init(items: [VaultCardViewModelType]) {
        self.items = items
    }
}


final class HomeViewModel: ObservableObject {
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    let cardService: PCardService
    let coinService: PCoinService
    
    var viewStackHandler = ViewStackHandler()
    private func observeStack() {
        viewStackHandler.$refreshVaults
            .sink { [weak self] newValue in
                if newValue == .clear {
                    self?.vaultCards = VaultsList(items: [])
                }
            }
            .store(in: &cancellables)
    }
    
    var cardVaults: CardVaults?
    @Published var vaultCards: VaultsList = VaultsList(items: []) {
        didSet {
            self.populateTabs()
        }
    }
    @Published var currentSlotIndex: Int = 0 {
        didSet {
            self.checkForNFTTab()
        }
    }
    @Published var cardStatus: CardStatusObservable = CardStatusObservable()
    @Published var nftListViewModel: NFTListViewModel = NFTListViewModel()
    @Published var tokenListViewModel: TokenListViewModel = TokenListViewModel()
    @Published var historyListViewModel: HistoryListViewModel = HistoryListViewModel()
    @Published var canSelectNFT: Bool = true
    
    var unsealViewModel: UnsealViewModel?
    var showPrivateKeyViewModel: ShowPrivateKeyMenuViewModel?
    var resetViewModel: ResetViewModel?
    
    // MARK: - Literals
    let viewTitle: String = "Vaults"
    
    // MARK: - Lifecycle
    init(cardService: PCardService, coinService: PCoinService) {
        self.cardService = cardService
        self.coinService = coinService
        self.observeStack()
    }
    
    // MARK: - Computed properties
    
    private func isFirstUse() -> Bool {
        let result = UserDefaults.standard.bool(forKey: Constants.Storage.isAppPreviouslyLaunched) == false
        return result
    }
    
    func gradientToDisplay() -> String {
        switch currentSlotIndex {
        case 0:
            return "gradient_1"
        case 1:
            return "gradient_2"
        case 2:
            return "gradient_3"
        default:
            return "gradient_1"
        }
    }
    
    func hasReadCard() -> Bool {
        return !self.vaultCards.items.isEmpty
    }
    
    func isUnsealButtonVisible() -> Bool {
        guard !self.vaultCards.items.isEmpty else { return false }
        switch self.vaultCards.items[currentSlotIndex] {
        case .vaultCard(let viewModel):
            return viewModel.vaultItem.isSealed()
        default:
            return false
        }
    }
    
    func isCurrentCardUnsealed() -> Bool {
        guard !self.vaultCards.items.isEmpty else { return false }
        switch self.vaultCards.items[currentSlotIndex] {
        case .vaultCard(let viewModel):
            return !viewModel.vaultItem.isSealed()
        default:
            return false
        }
    }
    
    private func checkForNFTTab() {
        guard !self.vaultCards.items.isEmpty else { return }
        let item = self.vaultCards.items[self.currentSlotIndex]
        switch item {
        case .vaultCard(let viewModel):
            let coin = viewModel.vaultItem.getCoinSymbol()
            // TODO: We should unify to way to recognize coin
            self.canSelectNFT = coin == "ETH" || coin == "XCP"
        default:
            break
        }
    }

    // MARK: - Navigation
    
    func evaluateBaseNavigation() {
        if isFirstUse() {
            navigateTo(destination: .onboarding)
        }
    }
    
    func goToMenuView() {
        self.navigateTo(destination: .menu)
    }
    
    func goToUnsealSlot() {
        guard !self.vaultCards.items.isEmpty else { return }
        
        let vaultCard = self.vaultCards.items[self.currentSlotIndex]
        switch vaultCard {
        case .vaultCard(let viewModel):
            self.unsealViewModel = UnsealViewModel(cardService: CardService(), vaultCardViewModel: viewModel, indexPosition: self.currentSlotIndex)
        case .emptyVault(_):
            break
        }
        self.navigateTo(destination: .unseal)
    }
    
    func goToShowKey() {
        guard !self.vaultCards.items.isEmpty else { return }
        
        let vaultCard = self.vaultCards.items[self.currentSlotIndex]
        switch vaultCard {
        case .vaultCard(let viewModel):
            self.showPrivateKeyViewModel = ShowPrivateKeyMenuViewModel(cardService: CardService(), vaultCardViewModel: viewModel, indexPosition: self.currentSlotIndex)
        case .emptyVault(_):
            break
        }
        self.navigateTo(destination: .privateKey)
    }
    
    func emptyCardSealTapped(id: Int) {
        self.navigateTo(destination: .vaultInitialization)
    }
    
    private func navigateTo(destination: NavigationState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewStackHandler.navigationState = destination
        }
    }
    
    // MARK: - NFC
    
    func startReadingCard() {
        self.cardService.getCardActionStateStatus { [weak self] status in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.cardStatus.status = .valid
            }
            switch status {
            case .unknown:
                break
            case .readingError(error: let error):
                DispatchQueue.main.async {
                    self.cardStatus.status = .invalid
                }
            case .silentError(error: let error):
                break
            case .notAuthentic:
                self.navigateTo(destination: .notAuthentic)
            case .needToAcceptCard:
                self.navigateTo(destination: .takeOwnership)
            case .cardAccepted:
                print("TODO - cardAccepted")
            case .setupDone:
                break
            case .isOwner:
                break
            case .notOwner:
                break
            case .getPrivate:
                break
            case .reset:
                break
            case .seal:
                break
            case .transfer:
                break
            case .unsealed:
                self.navigateTo(destination: .unseal)
            case .noVault:
                self.navigateTo(destination: .vaultInitialization)
            case .hasVault(vaults: let vaults):
                self.constructVaultsList(with: vaults)
            case .sealed(result: let result):
                break
            }
        }
    }
    
    func reset() {
        guard !self.vaultCards.items.isEmpty else { return }
        let vaultCard = self.vaultCards.items[self.currentSlotIndex]
        switch vaultCard {
        case .vaultCard(let viewModel):
            self.resetViewModel = ResetViewModel(cardService: CardService(), vaultCardViewModel: viewModel, indexPosition: self.currentSlotIndex, vaultsList: self.vaultCards)
        case .emptyVault(_):
            break
        }
        self.navigateTo(destination: .reset)
    }
    
    // MARK: - Data construction
    
    private func constructVaultsList(with data: CardVaults) {
        self.cardVaults = data
        self.vaultCards = VaultsList(items: [])
        self.nftListViewModel = NFTListViewModel()
        self.tokenListViewModel = TokenListViewModel()
        
        var vaults: [VaultCardViewModelType] = []
        
        for vault in data.vaults {
            if vault.isInitialized() {
                let viewModel = VaultCardViewModel(walletAddress: vault.address, vaultItem: vault, coinService: CoinService())
                vaults.append(.vaultCard(viewModel))
            } else {
                let viewModel = EmptyVaultViewModel(vaultItem: vault)
                vaults.append(.emptyVault(viewModel))
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.vaultCards = VaultsList(items: vaults)
            self.checkForNFTTab()
        }
    }
    
    func populateTabs() {
        guard !self.vaultCards.items.isEmpty else { return }
        
        switch self.vaultCards.items[currentSlotIndex] {
        case .vaultCard(let viewModel):
            Task {
                let assets = await self.coinService.fetchAssets(for: viewModel.vaultItem)
                DispatchQueue.main.async {
                    var nftImageUrlResults: [URL] = []
                    var tokensList: [TokenCellViewModel] = []
                    
                    for nftList in assets.nftList {
                        if let imageUri = nftList["nftImageUrl"], let imageUrl = URL(string: imageUri) {
                            nftImageUrlResults.append(imageUrl)
                        }
                    }
                    for tokenItem in assets.tokenList {
                        if let name = tokenItem["name"],
                           let tokenIconUrl = tokenItem["tokenIconUrl"],
                           let _ = tokenItem["contract"] {
                            let fiatBalance = viewModel.vaultItem.getTokenBalanceString(tokenData: tokenItem)
                            let cryptoBalance = viewModel.vaultItem.totalTokenValueInSecondCurrency
                            let tokenCellViewModel = TokenCellViewModel(
                                imageUri: tokenIconUrl,
                                name: name,
                                cryptoBalance: "\(cryptoBalance ?? 0.0)",
                                fiatBalance: fiatBalance)
                            tokensList.append(tokenCellViewModel)
                        }
                    }
                    
                    let nftListViewModel = NFTListViewModel()
                    nftListViewModel.populateCellViewModels(from: nftImageUrlResults)
                    self.nftListViewModel = nftListViewModel
                    
                    let tokenListViewModel = TokenListViewModel()
                    tokenListViewModel.populateCellViewModels(from: tokensList)
                    self.tokenListViewModel = tokenListViewModel
                    
                    let historyListViewModel = HistoryListViewModel()
                }
            }
        case .emptyVault(_):
            self.nftListViewModel = NFTListViewModel()
            self.tokenListViewModel = TokenListViewModel()
            break
        }
    }
}
