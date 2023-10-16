//
//  HomeViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
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

    init(walletAddress: String, vaultItem: VaultItem, coinService: PCoinService) {
        self.coinService = coinService
        self.walletAddress = walletAddress
        self.vaultItem = vaultItem
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
        self.imageName = vaultItem.iconPath
        self.balanceTitle = "Total balance"
        self.fiatBalance = "0"
        self.cardBackground = vaultItem.isSealed() ? self.sealedBackgroundImageName() : "bg_card_unsealed"
        
        Task {
            let cryptoBalance = await self.coinService.fetchCryptoBalance(for: vaultItem)
            DispatchQueue.main.async {
                self.cryptoBalance = "\(cryptoBalance) \(vaultItem.coin.coinSymbol)"
            }
            
            let fetchedFiatBalance = await self.coinService.fetchFiatBalance(for: vaultItem, with: cryptoBalance)
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
    @Published var currentSlotIndex: Int = 0
    @Published var cardStatus: CardStatusObservable = CardStatusObservable()
    @Published var nftListViewModel: NFTListViewModel = NFTListViewModel()
    @Published var tokenListViewModel: TokenListViewModel = TokenListViewModel()
    
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
                           let contract = tokenItem["contract"] {
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
                }
            }
        case .emptyVault(_):
            self.nftListViewModel = NFTListViewModel()
            self.tokenListViewModel = TokenListViewModel()
            break
        }
    }
}
