//
//  HomeView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI
import SnapToScroll

// TODO: do we need this?
enum RefreshVaults {
    case none
    case clear
    case refresh
}

class ViewStackHandler: ObservableObject {
    @Published var navigationState: NavigationState = .goBackHome
    @Published var refreshVaults: RefreshVaults = .none
}

class ViewStackHandlerNew: ObservableObject {
    @Published var navigationState: NavigationState = .goBackHome
    @Published var refreshVaults: RefreshVaults = .none
}


enum NavigationState {
    case goBackHome
    case onboarding
    case takeOwnership
    case vaultInitialization
    case notAuthentic
    case cardAuthenticity
    case unseal
    case privateKey
    case reset
    case menu
    case addFunds
}

struct HomeView: View {
    //@StateObject var logger = LoggerService()
    
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandlerNew: ViewStackHandlerNew // todo: rename
    @EnvironmentObject var logs: LoggerService
    
    // TODO: deprecate
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var viewStackHandler: ViewStackHandler
    
    @State private var currentSlotIndex: Int = 0
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        self.viewStackHandler = viewModel.viewStackHandler
    }
    
    func buildEmptyCardView(id: Int) -> some View {
        VaultCardEmpty(id: id) {
            viewModel.emptyCardSealTapped(id: id)
        }
        .frame(width: 261, height: 197)
        .snapAlignmentHelper(id: id)
    }
    
    var body: some View {
        NavigationView {
                ZStack {
                    Constants.Colors.viewBackground
                        .ignoresSafeArea()
                    
                    if viewModel.hasReadCard() {
                        VStack {
                            Image(viewModel.gradientToDisplay())
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height*0.5)
                                .clipped()
                                .ignoresSafeArea()
                            Spacer()
                        }
                    }
                    
                    VStack {
                        
                        // UI: Logo + vault title + refresh button + 3-dots menu
                        HStack {
                            SatoStatusView(cardStatus: self.viewModel.cardStatus) {
                                self.viewModel.gotoCardAuthenticity()
                            }
                            //.padding(.leading, 22) // TODO: remove comment
                            
                            Spacer()
                            
                            SatoText(text: viewModel.viewTitle, style: .title)
                            
                            Spacer()
                            
                            //if !viewModel.vaultCards.items.isEmpty {
                            if !cardState.vaultArray.isEmpty {
                                Button(action: {
                                    //viewModel.startReadingCard()
                                    Task {
                                        await cardState.executeQuery()
                                    }
                                    //currentSlotIndex = 0 // reset index to sync with HStackSnap??
                                }) {
                                    Image("ic_refresh")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }.padding(.trailing, 8)
                            }
                            
                            Button(action: {
                                viewModel.goToMenuView()
                            }) {
                                Image("ic_dots_vertical")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }.padding(.trailing, 22)
                        } // end hstack
                        .frame(height: 48)
                        
                        Spacer()
                            .frame(height: 16)
                        
//                        HStack {
//                            ForEach(cardState.vaultArray, id: \.self){ vault in
//                                VaultCardNew(index: vault.index)
//                                    .shadow(radius: 10)
//                                    .frame(width: 261, height: 197)
//                                    //.snapAlignmentHelper(id: vault.index)
//                            }
//                        }
                        
                        // UI: Cards horizontal stack display
                        // Quick hack as HStackSnap does not support dynamic data
                        //if viewModel.vaultVisibility != .makeVisible {
                        if cardState.vaultArray.isEmpty {
                            HStackSnap(alignment: .leading(20), spacing: 10) {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.clear, lineWidth: 2)
                                    .frame(width: 261, height: 197)
                                    .snapAlignmentHelper(id: 0)
                            } eventHandler: { event in
                                handleSnapToScrollEvent(event: event)
                            }
                            .frame(height: 197)
                        } else {
                            HStackSnap(alignment: .leading(20), spacing: 10) {
                                ForEach(cardState.vaultArray, id: \.self){ vault in
                                    VaultCardNew(index: vault.index)
                                        .shadow(radius: 10)
                                        .frame(width: 261, height: 197)
                                        .snapAlignmentHelper(id: vault.index)
                                }
                            } eventHandler: { event in
                                handleSnapToScrollEvent(event: event)
                            }
                            .frame(height: 197)
                        } // end HStackSnap
//                        if viewModel.vaultVisibility != .makeVisible {
//                            HStackSnap(alignment: .leading(20), spacing: 10) {
//                                RoundedRectangle(cornerRadius: 20)
//                                    .stroke(Color.clear, lineWidth: 2)
//                                    .frame(width: 261, height: 197)
//                                    .snapAlignmentHelper(id: 0)
//                            } eventHandler: { event in
//                                handleSnapToScrollEvent(event: event)
//                            }
//                            .frame(height: 197)
//                        } else {
//                            HStackSnap(alignment: .leading(20), spacing: 10) {
//                                ForEach(Array(viewModel.vaultCards.items.indices), id: \.self) { i in
//                                    let cardData = viewModel.vaultCards.items[i]
//                                    switch cardData {
//                                    case .vaultCard(let vaultCardViewModel):
//                                        VaultCard(viewModel: vaultCardViewModel, indexPosition: i)
//                                            .shadow(radius: 10)
//                                            .frame(width: 261, height: 197)
//                                            .snapAlignmentHelper(id: i)
//                                    case .emptyVault(_):
//                                        self.buildEmptyCardView(id: i)
//                                    }
//                                }
//                            } eventHandler: { event in
//                                handleSnapToScrollEvent(event: event)
//                            }
//                            .frame(height: 197)
//                        } // end HStackSnap
                        
                        Spacer()
                            .frame(height: 16)
                        
                        // UI action buttons for current slot
                        HStack(spacing: 18) {
                            // TODO: add link to explorer here?
                            if cardState.vaultArray.count > currentSlotIndex {
                                //                            if viewModel.isAddFundsButtonVisible() {
                                //                                AddFundsButton {
                                //                                    viewModel.goToAddFunds()
                                //                                }
                                //                            }
                                if cardState.vaultArray[currentSlotIndex].getStatus() != .uninitialized {
                                    AddFundsButton {
                                        //self.viewStackHandlerNew.navigationState = .addFunds
                                        self.navigateTo(destination: .addFunds)
                                    }
                                }
                                
                                //                            if viewModel.isUnsealButtonVisible() {
                                //                                UnsealButton {
                                //                                    viewModel.goToUnsealSlot()
                                //                                }
                                //                            }
                                if cardState.vaultArray[currentSlotIndex].getStatus() == .sealed {
                                    UnsealButton {
                                        //self.viewStackHandlerNew.navigationState = .unseal
                                        self.navigateTo(destination: .unseal)
                                    }
                                }
                                
                                //                            if viewModel.isCurrentCardUnsealed() {
                                //                                ShowKeyButton {
                                //                                    viewModel.goToShowKey()
                                //                                }
                                //
                                //                                ResetButton {
                                //                                    viewModel.reset()
                                //                                }
                                //                            }
                                if cardState.vaultArray[currentSlotIndex].getStatus() == .unsealed {
                                    ShowKeyButton {
                                        //self.viewStackHandlerNew.navigationState = .privateKey
                                        self.navigateTo(destination: .privateKey)
                                    }
                                    ResetButton {
                                        //self.viewStackHandlerNew.navigationState = .reset
                                        self.navigateTo(destination: .reset)
                                    }
                                }
                            } // end if vaultArray.count
                        } // end hstack action buttons
                        
                        Spacer()
                            .frame(height: 16)
                        
                        // UI: Tokens & NFT tabs
//                        if viewModel.hasReadCard() && !viewModel.vaultCards.items.isEmpty {
//                            switch viewModel.vaultCards.items[viewModel.currentSlotIndex] {
//                            case .emptyVault(_):
//                                Spacer()
//                            case .vaultCard(_):
//                                SatoTabView(nftListViewModel: self.viewModel.nftListViewModel,
//                                            tokenListViewModel: self.viewModel.tokenListViewModel,
//                                            canSelectNFT: $viewModel.canSelectNFT)
//                                .padding([.leading, .trailing], 13)
//                            }
                        if cardState.vaultArray.count > currentSlotIndex
                            && cardState.vaultArray[currentSlotIndex].getStatus() != .uninitialized
                        {
                            AssetTabView(index: currentSlotIndex, canSelectNFT: cardState.vaultArray[currentSlotIndex].coin.supportNft)
                        } else {
                            Spacer()
                        }
                    } // end main vStack
                    
                    // Navigation config new
//                    if self.viewStackHandlerNew.navigationState == .onboarding {
//                        NavigationLink("", destination: OnboardingContainerView(viewModel: OnboardingContainerViewModel()), isActive: .constant(isOnboarding())).hidden()
//                    }
//                    if viewModel.viewStackHandler.navigationState == .cardAuthenticity, viewModel.cardStatus.status != .none {
//                        NavigationLink("", destination: AuthenticView(viewModel: AuthenticViewModel(authState: viewModel.cardStatus.status == .valid ? .isAuthentic : .notAuthentic)), isActive: .constant(isCardAuthenticity())).hidden()
//                    }
//                    if viewModel.viewStackHandler.navigationState == .notAuthentic {
//                        NavigationLink("", destination: AuthenticView(viewModel: AuthenticViewModel(authState: .notAuthentic, viewStackHandler: viewModel.viewStackHandler, destinationOnClose: viewModel.vaultCards.areAllEmptyVaults() && !viewModel.doesUserRequestToSeeAuthenticScreen ? .vaultInitialization : nil)), isActive: .constant(isNotAuthentic())).hidden()
//                    }
//                    if viewModel.viewStackHandler.navigationState == .takeOwnership, let cardVaults = viewModel.cardVaults {
//                        NavigationLink("", destination: TakeOwnershipView(viewModel: TakeOwnershipViewModel(cardService: CardService(), cardVaults: cardVaults, viewStackHandler: viewStackHandler, destinationOnClose: viewModel.cardVaults?.isCardAuthentic == .notAuthentic ? .notAuthentic : nil)), isActive: .constant(isTakeOwnership())).hidden()
//                    }
//                    if viewModel.viewStackHandler.navigationState == .vaultInitialization {
//                        NavigationLink("", destination: VaultSetupSelectChainView(viewModel: VaultSetupSelectChainViewModel(index: viewModel.currentSlotIndex, vaultCards: viewModel.vaultCards)), isActive: .constant(isVaultInitialization())).hidden()
//                    }
//                    if viewModel.viewStackHandler.navigationState == .menu {
//                        NavigationLink("", destination: MenuView(viewModel: MenuViewModel(cardVaults: viewModel.cardVaults)), isActive: .constant(isMenu())).hidden()
//                        // TODO: isMenu() returns "viewModel.viewStackHandler.navigationState == .menu"
//                        // replace with isActive: True ??
//                    }
//                    if viewModel.viewStackHandler.navigationState == .unseal, let viewModel = self.viewModel.unsealViewModel {
//                        NavigationLink("", destination: UnsealView(viewModel: viewModel), isActive: .constant(isUnseal())).hidden()
//                    }
//                    if viewModel.viewStackHandler.navigationState == .privateKey, let viewModel = self.viewModel.buildShowPrivateKeyVM(viewStackHandler: self.viewStackHandler) {
//                        NavigationLink("", destination: ShowPrivateKeyMenuView(viewModel: viewModel), isActive: .constant(isPrivateKey())).hidden()
//                    }
//                    if viewModel.viewStackHandler.navigationState == .reset, let viewModel = self.viewModel.resetViewModel {
//                        NavigationLink("", destination: ResetView(viewModel: viewModel), isActive: .constant(isReset())).hidden()
//                    }
                    if self.viewStackHandlerNew.navigationState == .addFunds {
                        NavigationLink("", destination: AddFundsViewNew(index: currentSlotIndex), isActive: .constant(true)).hidden()
                    }
                    
                    // DEPRECATED
                    // Navigation config
                    if viewModel.viewStackHandler.navigationState == .onboarding {
                        NavigationLink("", destination: OnboardingContainerView(viewModel: OnboardingContainerViewModel()), isActive: .constant(isOnboarding())).hidden()
                    }
                    if viewModel.viewStackHandler.navigationState == .cardAuthenticity, viewModel.cardStatus.status != .none {
                        NavigationLink("", destination: AuthenticView(viewModel: AuthenticViewModel(authState: viewModel.cardStatus.status == .valid ? .isAuthentic : .notAuthentic)), isActive: .constant(isCardAuthenticity())).hidden()
                    }
                    if viewModel.viewStackHandler.navigationState == .notAuthentic {
                        NavigationLink("", destination: AuthenticView(viewModel: AuthenticViewModel(authState: .notAuthentic, viewStackHandler: viewModel.viewStackHandler, destinationOnClose: viewModel.vaultCards.areAllEmptyVaults() && !viewModel.doesUserRequestToSeeAuthenticScreen ? .vaultInitialization : nil)), isActive: .constant(isNotAuthentic())).hidden()
                    }
                    if viewModel.viewStackHandler.navigationState == .takeOwnership, let cardVaults = viewModel.cardVaults {
                        NavigationLink("", destination: TakeOwnershipView(viewModel: TakeOwnershipViewModel(cardService: CardService(), cardVaults: cardVaults, viewStackHandler: viewStackHandler, destinationOnClose: viewModel.cardVaults?.isCardAuthentic == .notAuthentic ? .notAuthentic : nil)), isActive: .constant(isTakeOwnership())).hidden()
                    }
                    if viewModel.viewStackHandler.navigationState == .vaultInitialization {
                        NavigationLink("", destination: VaultSetupSelectChainView(viewModel: VaultSetupSelectChainViewModel(index: viewModel.currentSlotIndex, vaultCards: viewModel.vaultCards)), isActive: .constant(isVaultInitialization())).hidden()
                    }
                    if viewModel.viewStackHandler.navigationState == .menu {
                        NavigationLink("", destination: MenuView(viewModel: MenuViewModel(cardVaults: viewModel.cardVaults)), isActive: .constant(isMenu())).hidden()
                        // TODO: isMenu() returns "viewModel.viewStackHandler.navigationState == .menu"
                        // replace with isActive: True ??
                    }
                    if viewModel.viewStackHandler.navigationState == .unseal, let viewModel = self.viewModel.unsealViewModel {
                        NavigationLink("", destination: UnsealView(viewModel: viewModel), isActive: .constant(isUnseal())).hidden()
                    }
                    if viewModel.viewStackHandler.navigationState == .privateKey, let viewModel = self.viewModel.buildShowPrivateKeyVM(viewStackHandler: self.viewStackHandler) {
                        NavigationLink("", destination: ShowPrivateKeyMenuView(viewModel: viewModel), isActive: .constant(isPrivateKey())).hidden()
                    }
                    if viewModel.viewStackHandler.navigationState == .reset, let viewModel = self.viewModel.resetViewModel {
                        NavigationLink("", destination: ResetView(viewModel: viewModel), isActive: .constant(isReset())).hidden()
                    }
                    if viewModel.viewStackHandler.navigationState == .addFunds, let vaultItem = viewModel.cardVaults?.vaults[viewModel.currentSlotIndex] {
                        switch viewModel.vaultCards.items[viewModel.currentSlotIndex] {
                        case .vaultCard(let cardViewModel):
                            NavigationLink("", destination: AddFundsView(viewModel: AddFundsViewModel(indexPosition: viewModel.currentSlotIndex, vault: vaultItem, card: cardViewModel, viewStackHandler: self.viewStackHandler)), isActive: .constant(isAddFunds())).hidden()
                        case .emptyVault(_):
                            EmptyView()
                        }
                    }
                }
                .overlay(
                    Group {
                        if viewModel.showOwnershipAlert {
                            ZStack {
                                Color.black.opacity(0.4)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        viewModel.showOwnershipAlert = false
                                    }
                                
                                SatoAlertView(isPresented: $viewModel.showOwnershipAlert, alert: viewModel.ownershipAlert)
                                    .padding([.leading, .trailing], 24)
                            }
                        }
                        // TODO: show authenticity issue here?
                        
                        //if !viewModel.hasReadCard() {
                        if cardState.vaultArray.isEmpty {
                            ScanButton {
                                //viewModel.startReadingCard()
                                Task {
                                    await cardState.executeQuery()
                                }
                            }
                        }
                    }
                )
        }
        .environmentObject(viewModel.viewStackHandler)
        .onAppear {
            viewModel.evaluateBaseNavigation()
        }
    }
    
    func handleSnapToScrollEvent(event: SnapToScrollEvent) {
        switch event {
            case let .didLayout(layoutInfo: layoutInfo):
            print("\(layoutInfo.keys.count) items layed out")
            //currentSlotIndex = 0 // debug???
            case let .swipe(index: index):
            currentSlotIndex = index
            viewModel.currentSlotIndex = index
            viewModel.populateTabs()
            print("swiped to index: \(index)")
        }
    }
    
    func navigateTo(destination: NavigationState) {
        DispatchQueue.main.async {
            self.viewStackHandlerNew.navigationState = destination
        }
    }
    
    // TODO: do we really need these?
    func isCardAuthenticity() -> Bool {
        viewModel.viewStackHandler.navigationState == .cardAuthenticity
    }

    func isOnboarding() -> Bool {
        viewModel.viewStackHandler.navigationState == .onboarding
    }

    func isVaultInitialization() -> Bool {
        viewModel.viewStackHandler.navigationState == .vaultInitialization
    }
    
    func isMenu() -> Bool {
        viewModel.viewStackHandler.navigationState == .menu
    }
    
    func isUnseal() -> Bool {
        viewModel.viewStackHandler.navigationState == .unseal
    }
    
    func isReset() -> Bool {
        viewModel.viewStackHandler.navigationState == .reset
    }
    
    func isPrivateKey() -> Bool {
        viewModel.viewStackHandler.navigationState == .privateKey
    }
    
    func isTakeOwnership() -> Bool {
        viewModel.viewStackHandler.navigationState == .takeOwnership
    }
    
    func isNotAuthentic() -> Bool {
        viewModel.viewStackHandler.navigationState == .notAuthentic
    }
    
    func isAddFunds() -> Bool {
        viewModel.viewStackHandler.navigationState == .addFunds
    }
    
    // TODO: remove (unused)
    func hasNoOwnership() -> Bool {
        return true
    }
    
    // TODO: remove (unused)
    func isVaultInitialized() -> Bool {
        return UserDefaults.standard.bool(forKey: "VaultInitialized")
    }
    
    // debug
    func debug(txt:String){
        print(txt)
    }
}
