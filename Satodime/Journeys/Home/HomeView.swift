//
//  HomeView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI
import SnapToScroll

enum RefreshVaults {
    case none
    case clear
}

class ViewStackHandler: ObservableObject {
    @Published var navigationState: NavigationState = .goBackHome
    @Published var refreshVaults: RefreshVaults = .none
}

enum NavigationState {
    case goBackHome
    case onboarding
    case takeOwnership
    case vaultInitialization
    case notAuthentic
    case unseal
    case privateKey
    case reset
    case menu
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var viewStackHandler: ViewStackHandler
    
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
                
                // TODO: Find gradient issue
                /*VStack {
                    Image("gradient_1")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height*0.8)
                        .clipped()
                        .ignoresSafeArea()
                    Spacer()
                }.frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)*/
                VStack {
                    HStack {
                        SatoStatusView(cardStatus: self.viewModel.cardStatus)
                            .padding(.leading, 22)
                        
                        Spacer()
                        
                        SatoText(text: viewModel.viewTitle, style: .title)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.goToMenuView()
                        }) {
                            Image("ic_dots_vertical")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }.padding(.trailing, 22)
                    }
                    .frame(height: 48)
                    
                    Spacer()
                        .frame(height: 16)
                    
                    HStackSnap(alignment: .leading(20), spacing: 10) {
                        ForEach(Array(viewModel.vaultCards.items.indices), id: \.self) { i in
                            let cardData = viewModel.vaultCards.items[i]
                            switch cardData {
                            case .vaultCard(let vaultCardViewModel):
                                VaultCard(viewModel: vaultCardViewModel, indexPosition: i)
                                    .frame(width: 261, height: 197)
                                    .snapAlignmentHelper(id: i)
                            case .emptyVault(_):
                                self.buildEmptyCardView(id: i)
                            }
                        }
                    } eventHandler: { event in
                        handleSnapToScrollEvent(event: event)
                    }
                    .frame(height: 197)
                    
                    Spacer()
                        .frame(height: 16)
                    
                    if !viewModel.hasReadCard() {
                        ScanButton {
                            viewModel.startReadingCard()
                        }
                    }
                    
                    Spacer()
                        .frame(height: 16)
                    
                    HStack(spacing: 18) {
                        if viewModel.isUnsealButtonVisible() {
                            UnsealButton {
                                viewModel.goToUnsealSlot()
                            }
                        }
                        
                        if viewModel.isCurrentCardUnsealed() {
                            ShowKeyButton {
                                viewModel.goToShowKey()
                            }
                            
                            ResetButton {
                                viewModel.reset()
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 16)
                    
                    if viewModel.hasReadCard() && !viewModel.vaultCards.items.isEmpty {
                        switch viewModel.vaultCards.items[viewModel.currentSlotIndex] {
                        case .emptyVault(_):
                            Spacer()
                        case .vaultCard(_):
                            SatoTabView(nftListViewModel: self.viewModel.nftListViewModel,
                                        tokenListViewModel: self.viewModel.tokenListViewModel)
                            .padding([.leading, .trailing], 13)
                        }
                    } else {
                        Spacer()
                    }
                }
                
                if viewModel.viewStackHandler.navigationState == .onboarding {
                    NavigationLink("", destination: OnboardingContainerView(viewModel: OnboardingContainerViewModel()), isActive: .constant(isOnboarding())).hidden()
                }
                if viewModel.viewStackHandler.navigationState == .notAuthentic {
                    NavigationLink("", destination: AuthenticView(viewModel: AuthenticViewModel(authState: .notAuthentic)), isActive: .constant(isNotAuthentic())).hidden()
                }
                if viewModel.viewStackHandler.navigationState == .takeOwnership {
                    NavigationLink("", destination: TakeOwnershipView(viewModel: TakeOwnershipViewModel(cardService: CardService())), isActive: .constant(isTakeOwnership())).hidden()
                }
                if viewModel.viewStackHandler.navigationState == .vaultInitialization {
                    NavigationLink("", destination: VaultSetupSelectChainView(viewModel: VaultSetupSelectChainViewModel(index: viewModel.currentSlotIndex, vaultCards: viewModel.vaultCards)), isActive: .constant(isVaultInitialization())).hidden()
                }
                if viewModel.viewStackHandler.navigationState == .menu {
                    NavigationLink("", destination: MenuView(viewModel: MenuViewModel(cardVaults: viewModel.cardVaults)), isActive: .constant(isMenu())).hidden()
                }
                if viewModel.viewStackHandler.navigationState == .unseal, let viewModel = self.viewModel.unsealViewModel {
                    NavigationLink("", destination: UnsealView(viewModel: viewModel), isActive: .constant(isUnseal())).hidden()
                }
                if viewModel.viewStackHandler.navigationState == .privateKey, let viewModel = self.viewModel.showPrivateKeyViewModel {
                    NavigationLink("", destination: ShowPrivateKeyMenuView(viewModel: viewModel), isActive: .constant(isPrivateKey())).hidden()
                }
                if viewModel.viewStackHandler.navigationState == .reset, let viewModel = self.viewModel.resetViewModel {
                    NavigationLink("", destination: ResetView(viewModel: viewModel), isActive: .constant(isReset())).hidden()
                }
            }
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
            case let .swipe(index: index):
            viewModel.currentSlotIndex = index
            viewModel.populateTabs()
            print("swiped to index: \(index)")
        }
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
    
    func hasNoOwnership() -> Bool {
        return true
    }

    func isVaultInitialized() -> Bool {
        return UserDefaults.standard.bool(forKey: "VaultInitialized")
    }
}