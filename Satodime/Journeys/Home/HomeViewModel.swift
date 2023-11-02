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
                guard let self = self else { return }
                if newValue == .clear {
                    DispatchQueue.main.async {
                        self.vaultCards = VaultsList(items: [])
                    }
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
            self.checkNFTTabCanBeEnabled()
        }
    }
    @Published var showOwnershipAlert = false
    @Published var cardStatus: CardStatusObservable = CardStatusObservable()
    @Published var nftListViewModel: NFTListViewModel = NFTListViewModel()
    @Published var tokenListViewModel: TokenListViewModel = TokenListViewModel()
    // @Published var historyListViewModel: HistoryListViewModel = HistoryListViewModel() // For later use
    @Published var canSelectNFT: Bool = true
    
    var unsealViewModel: UnsealViewModel?
    var showPrivateKeyViewModel: ShowPrivateKeyMenuViewModel?
    var resetViewModel: ResetViewModel?
    
    let ownershipAlert: SatoAlert = SatoAlert(title: "Ownership", message: "You are not the owner of this card, so you cannot perform sensitive operations on vaults, such as:\n\n-Create and Seal\n-Unseal\n-Delete\n\nGet more information on how the get the ownership by cliking here.", buttonTitle: "More info", buttonAction: {
            guard let url = URL(string: "https://satochip.io") else {
                print("Invalid URL")
                return
            }
        UIApplication.shared.open(url)
    })
    
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
        guard !self.vaultCards.items.isEmpty else { return "" }
        switch self.vaultCards.items[currentSlotIndex] {
        case .emptyVault(_):
            return ""
        default:
            break
        }
        
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
    
    private func checkNFTTabCanBeEnabled() {
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
        guard let isOwner = self.cardVaults?.isOwner, isOwner else {
            self.showOwnershipAlert = true
            return
        }
        
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
        guard let isOwner = self.cardVaults?.isOwner, isOwner else {
            self.showOwnershipAlert = true
            return
        }
        
        let vaultCard = self.vaultCards.items[self.currentSlotIndex]
        switch vaultCard {
        case .vaultCard(let viewModel):
            self.showPrivateKeyViewModel = ShowPrivateKeyMenuViewModel(cardService: CardService(), vaultCardViewModel: viewModel, indexPosition: self.currentSlotIndex)
        case .emptyVault(_):
            break
        }
        self.navigateTo(destination: .privateKey)
    }
    
    func reset() {
        guard !self.vaultCards.items.isEmpty else { return }
        guard let isOwner = self.cardVaults?.isOwner, isOwner else {
            self.showOwnershipAlert = true
            return
        }
        
        let vaultCard = self.vaultCards.items[self.currentSlotIndex]
        switch vaultCard {
        case .vaultCard(let viewModel):
            self.resetViewModel = ResetViewModel(cardService: CardService(), vaultCardViewModel: viewModel, indexPosition: self.currentSlotIndex, vaultsList: self.vaultCards)
        case .emptyVault(_):
            break
        }
        self.navigateTo(destination: .reset)
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
            switch status {
            case .unknown:
                break
            case .readingError(error: _):
                DispatchQueue.main.async {
                    self.cardStatus.status = .invalid
                }
            case .silentError(error: _):
                break
            case .notAuthentic(vaults: let vaults):
                DispatchQueue.main.async {
                    self.cardStatus.status = .valid
                    self.constructVaultsList(with: vaults)
                    self.navigateTo(destination: .notAuthentic)
                }
            case .needToAcceptCard:
                self.navigateTo(destination: .takeOwnership)
            case .cardAccepted:
                print("TODO - cardAccepted")
            case .setupDone:
                break
            case .isOwner:
                break
            case .notOwner(vaults: let vaults):
                DispatchQueue.main.async {
                    self.cardStatus.status = .valid
                    self.constructVaultsList(with: vaults)
                    self.showOwnershipAlert = true
                }
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
            case .noVaultSet(vaults: let vaults):
                DispatchQueue.main.async {
                    self.cardStatus.status = .valid
                    self.constructVaultsList(with: vaults)
                    self.navigateTo(destination: .vaultInitialization)
                }
            case .hasVault(vaults: let vaults):
                DispatchQueue.main.async {
                    self.cardStatus.status = .valid
                    self.constructVaultsList(with: vaults)
                }
            case .sealed(result: _):
                break
            }
        }
    }

    // MARK: - Data construction
    
    private func constructVaultsList(with data: CardVaults) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.cardVaults = data
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
            
            self.vaultCards = VaultsList(items: vaults)
            self.checkNFTTabCanBeEnabled()
        }
    }
    
    // Temporary fix as we do not get a correct url for now from the framework
    // eg.:
    // ipfs://ipfs/bafybeia4kfavwju5gjjpilerm2azdoxvpazff6fmtatqizdpbmcolpsjci/image.png"
    // instead of :
    // https://ipfs.io/ipfs/bafybeia4kfavwju5gjjpilerm2azdoxvpazff6fmtatqizdpbmcolpsjci/image.png
    private func getCorrectNFTUri(input: String) -> String {
        if input.hasPrefix("ipfs://") {
            let replacedString = input.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/")
            return replacedString
        }
        return input
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
                        if let imageUri = nftList["nftImageUrl"], let imageUrl = URL(string: self.getCorrectNFTUri(input: imageUri)) {
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
                    
                    // let historyListViewModel = HistoryListViewModel() // For later use
                }
            }
        case .emptyVault(_):
            self.nftListViewModel = NFTListViewModel()
            self.tokenListViewModel = TokenListViewModel()
            break
        }
    }
}
