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
    @Published var guid: String = UUID().uuidString

    init(items: [VaultCardViewModelType]) {
        self.items = items
    }
    
    func areAllEmptyVaults() -> Bool {
        return self.items.allSatisfy {
            if case .emptyVault = $0 {
                return true
            } else {
                return false
            }
        }
    }
}

enum VaultsVisibility  {
    case makeVisible
    case idle
    case invisible
}


final class HomeViewModel: ObservableObject {
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    let cardService: PCardService
    let coinService: PCoinService
    @Published var vaultVisibility: VaultsVisibility = .invisible //TODO: document
    
    var doesUserRequestToSeeAuthenticScreen: Bool = false // TODO: document
    
    var viewStackHandler = ViewStackHandler()
    private func observeStack() { // TODO: document
        viewStackHandler.$refreshVaults
            .sink { [weak self] newValue in
                guard let self = self else { return }
                if newValue == .clear {
                    DispatchQueue.main.async {
                        self.cardStatus.status = .none
                        self.vaultCards = VaultsList(items: [])
                        self.viewStackHandler.refreshVaults = .none
                    }
                }
                if newValue == .refresh {
                    DispatchQueue.main.async {
                        self.vaultVisibility = .idle
                        self.vaultVisibility = .makeVisible
                        self.viewStackHandler.refreshVaults = .none
                        self.populateTabs()
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
            self.buildShowPrivateKeyVM(viewStackHandler: self.viewStackHandler)
            self.checkNFTTabCanBeEnabled()
            
        }
    }
    @Published var showOwnershipAlert = false
    @Published var cardStatus: CardStatusObservable = CardStatusObservable() // TODO: try to remove?
    @Published var nftListViewModel: NFTListViewModel = NFTListViewModel()
    @Published var tokenListViewModel: TokenListViewModel = TokenListViewModel()
    // @Published var historyListViewModel: HistoryListViewModel = HistoryListViewModel() // For later use
    @Published var canSelectNFT: Bool = true
    
    var unsealViewModel: UnsealViewModel?
    var showPrivateKeyViewModel: ShowPrivateKeyMenuViewModel?
    var resetViewModel: ResetViewModel?
    var emptyVaultsStateList: [RoundedRectangle] = []
    
    let ownershipAlert: SatoAlert = SatoAlert(title: "ownership", message: "ownershipText", buttonTitle: String(localized:"moreInfo"), buttonAction: {
            guard let url = URL(string: "https://satochip.io/satodime-ownership-explained/") else {
                print("Invalid URL")
                return
            }
        UIApplication.shared.open(url)
    })
    
    // MARK: - Literals
    let viewTitle: String = "vaults"
    
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
        //TODO: use modulo 3?
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
    
    func isAddFundsButtonVisible() -> Bool {
        guard !self.vaultCards.items.isEmpty else { return false }
        switch self.vaultCards.items[currentSlotIndex] {
        case .vaultCard(_):
            return true
        default:
            return false
        }
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
    
    // TODO: same as isUnsealButtonVisible
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
            // TODO: We should unify the way to recognize coin
            self.canSelectNFT = coin == "ETH" || coin == "XCP" || coin == "ROP"
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
    
    func goToAddFunds() {
        guard !self.vaultCards.items.isEmpty else { return }
        self.navigateTo(destination: .addFunds)
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
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.unsealViewModel = UnsealViewModel(cardService: CardService(), vaultCardViewModel: viewModel, indexPosition: self.currentSlotIndex)
                self.navigateTo(destination: .unseal)
            }
        case .emptyVault(_):
            break
        }
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
            self.navigateTo(destination: .privateKey)
        case .emptyVault(_):
            break
        }
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
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.resetViewModel = ResetViewModel(cardService: CardService(), vaultCardViewModel: viewModel, indexPosition: self.currentSlotIndex, vaultsList: self.vaultCards)
                self.navigateTo(destination: .reset)
            }
        case .emptyVault(_):
            break
        }
    }
    
    func buildShowPrivateKeyVM(viewStackHandler: ViewStackHandler) -> ShowPrivateKeyMenuViewModel? {
        guard !self.vaultCards.items.isEmpty else { return nil }
        let vaultCard = self.vaultCards.items[self.currentSlotIndex]
        switch vaultCard {
        case .vaultCard(let viewModel):
            self.showPrivateKeyViewModel = ShowPrivateKeyMenuViewModel(cardService: CardService(), vaultCardViewModel: viewModel, indexPosition: self.currentSlotIndex, viewStackHandler: viewStackHandler)
            return self.showPrivateKeyViewModel
        case .emptyVault(_):
            return nil
        }
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
    
    // deprecated?
    func gotoCardAuthenticity() {
        guard self.cardStatus.status != .none else { return }
        self.doesUserRequestToSeeAuthenticScreen = true
        self.navigateTo(destination: .cardAuthenticity)
    }
    
    // MARK: - NFC
    
    private func clearData(completion: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.cardVaults = nil
            self.vaultCards = VaultsList(items: [])
            self.nftListViewModel = NFTListViewModel()
            self.tokenListViewModel = TokenListViewModel()
            self.cardStatus.status = .none
            self.currentSlotIndex = 0
            self.vaultVisibility = .invisible
            completion()
        }
    }
    
    func startReadingCard() {
        self.clearData { [weak self] in
            guard let self = self else { return }
            self.cardService.getCardActionStateStatus { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .unknown:
                    // TODO: logs + ?
                    break
                case .readingError(error: _):
                    DispatchQueue.main.async {
                        self.cardStatus.status = .invalid
                    }
                case .silentError(error: _):
                    // TODO: logs
                    break
                case .notAuthentic(vaults: let vaults):
                    DispatchQueue.main.async {
                        self.doesUserRequestToSeeAuthenticScreen = false
                        self.vaultVisibility = .idle // TODO: remove?
                        self.vaultVisibility = .makeVisible
                        self.cardStatus.status = .invalid
                        self.constructVaultsList(with: vaults)
                        self.navigateTo(destination: .notAuthentic)
                    }
                case .needToAcceptCard(vaults: let vaults):
                    DispatchQueue.main.async {
                        self.vaultVisibility = .idle // TODO: remove?
                        self.vaultVisibility = .makeVisible
                        if vaults.isCardAuthentic == .authentic { // todo: merge cardStatus & isCardAuthentic??
                            self.cardStatus.status = .valid
                        }
                        if vaults.isCardAuthentic == .notAuthentic {
                            self.cardStatus.status = .invalid
                        }
                        if vaults.isCardAuthentic == .unknown {
                            self.cardStatus.status = .none
                        }
                        self.constructVaultsList(with: vaults)
                        self.navigateTo(destination: .takeOwnership)
                    }
                case .cardAccepted:
                    print("TODO - cardAccepted")
                case .setupDone:
                    break
                case .isOwner:
                    break
                case .notOwner(vaults: let vaults):
                    DispatchQueue.main.async {
                        self.vaultVisibility = .idle
                        self.vaultVisibility = .makeVisible
                        if vaults.isCardAuthentic == .authentic {
                            self.cardStatus.status = .valid
                        }
                        if vaults.isCardAuthentic == .notAuthentic {
                            self.cardStatus.status = .invalid
                            // self.navigateTo(destination: .notAuthentic)
                        }
                        if vaults.isCardAuthentic == .unknown {
                            self.cardStatus.status = .none
                        }
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
                        self.vaultVisibility = .idle
                        self.vaultVisibility = .makeVisible
                        if vaults.isCardAuthentic == .authentic {
                            self.cardStatus.status = .valid
                        }
                        if vaults.isCardAuthentic == .notAuthentic {
                            self.cardStatus.status = .invalid
                        }
                        if vaults.isCardAuthentic == .unknown {
                            self.cardStatus.status = .none
                        }
                        self.constructVaultsList(with: vaults)
                        self.navigateTo(destination: .vaultInitialization)
                    }
                case .hasVault(vaults: let vaults):
                    DispatchQueue.main.async {
                        self.vaultVisibility = .idle
                        self.vaultVisibility = .makeVisible
                        if vaults.isCardAuthentic == .authentic {
                            self.cardStatus.status = .valid
                        }
                        if vaults.isCardAuthentic == .notAuthentic {
                            self.cardStatus.status = .invalid
                            self.navigateTo(destination: .notAuthentic)
                        }
                        if vaults.isCardAuthentic == .unknown {
                            self.cardStatus.status = .none
                        }
                        self.constructVaultsList(with: vaults)
                    }
                case .sealed(result: _):
                    break
                }
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
                    let viewModel = VaultCardViewModel(walletAddress: vault.address, vaultItem: vault, coinService: CoinService(), isTestnet: vault.coin.isTestnet, addressWebLink: vault.coin.getAddressWebLink(address: vault.address))
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
    
    // TODO: Temporary fix as we do not get a correct url for now from the framework
    // TODO: see getNftImageUrlString() in VaultItem
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
    
    func getBalanceRoundedValue(originalString: String, with decimals: Int) -> String {
        if let doubleValue = Double(originalString) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = decimals
            formatter.minimumFractionDigits = 2
            
            if let formattedString = formatter.string(from: NSNumber(value: doubleValue)) {
                return formattedString
            }
        }
        return originalString
    }
    
    func populateTabs() {
        guard !self.vaultCards.items.isEmpty else { return }
        
        // Clear tabs
        let nftListViewModel = NFTListViewModel()
        self.nftListViewModel = nftListViewModel // TODO: why 2 lines??
        let tokenListViewModel = TokenListViewModel()
        self.tokenListViewModel = tokenListViewModel
        
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
                    
                    let mainTokenItem = TokenCellViewModel(
                        imageUri: viewModel.imageName,
                        name: viewModel.vaultItem.getCoinDenominationString(),
                        symbol: viewModel.vaultItem.getCoinSymbol(),
                        cryptoBalance: "\(assets.mainCryptoBalance)",
                        fiatBalance: "\(assets.mainCryptoFiatBalance)",
                        mainToken: viewModel.vaultItem.getCoinSymbol())
                    
                    tokensList.append(mainTokenItem)
                    
                    // tokenValueInFirstCurrency eg.: in ETH
                    // tokenValueInSecondCurrency eg.: in EUR
                    
                    for tokenItem in assets.tokenList {
                        
                        let name = tokenItem["name"] ?? "?"
                        let symbol = tokenItem["symbol"] ?? ""
                        let tokenIconUrl = tokenItem["tokenIconUrl"] ?? ""
                        //let _ = tokenItem["contract"]
                        let fiatBalance = self.getBalanceRoundedValue(originalString: tokenItem["tokenValueInSecondCurrency"] ?? "0.0", with: 2)
                        let cryptoBalance = self.getBalanceRoundedValue(originalString: tokenItem["balance"] ?? "0.0", with: 7) // TODO: divide by decimals!
//                        let cryptoBalance = self.getBalanceRoundedValue(originalString: tokenItem["tokenValueInFirstCurrency"] ?? "0.0", with: 7)
                        //let cryptoBalance = self.getBalanceRoundedValue(originalString: tokenItem["tokenBalance"] ?? "0.0", with: 7)
                        let tokenCellViewModel = TokenCellViewModel(
                            imageUri: tokenIconUrl,
                            name: name,
                            symbol: symbol,
                            cryptoBalance: cryptoBalance,
                            fiatBalance: fiatBalance)
                        tokensList.append(tokenCellViewModel)
                        
//                        if let name = tokenItem["name"],
//                           let tokenIconUrl = tokenItem["tokenIconUrl"],
//                           let _ = tokenItem["contract"] {
//                            let fiatBalance = self.getBalanceRoundedValue(originalString: tokenItem["tokenValueInSecondCurrency"] ?? "0.0", with: 2)
//                            let cryptoBalance = self.getBalanceRoundedValue(originalString: tokenItem["tokenBalance"] ?? "0.0", with: 7)
//                            let tokenCellViewModel = TokenCellViewModel(
//                                imageUri: tokenIconUrl,
//                                name: name,
//                                cryptoBalance: cryptoBalance,
//                                fiatBalance: fiatBalance)
//                            tokensList.append(tokenCellViewModel)
//                        }
                    }
                    
                    
                    nftListViewModel.populateCellViewModels(from: nftImageUrlResults)
                    self.nftListViewModel = nftListViewModel

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
    } // populateTabs
}
