//
//  HomeView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI
import SnapToScroll

class ViewStackHandler: ObservableObject {
    @Published var navigationState: NavigationState = .goBackHome
}

enum NavigationState {
    case goBackHome
    case onboarding
    case takeOwnership
    case vaultInitialization
}

struct HomeView: View {
    @ObservedObject var viewStackHandler: ViewStackHandler = ViewStackHandler()
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.viewBackground
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        SatoStatusView()
                            .padding(.leading, 22)
                        
                        Spacer()
                        
                        SatoText(text: viewModel.viewTitle, style: .viewTitle)
                        
                        Spacer()
                        
                        Button(action: {
                            
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
                        ForEach(0..<viewModel.vaultCards.count) { i in
                            let cardData = viewModel.vaultCards[i]
                            switch cardData {
                            case .vaultCard(let vaultCardViewModel):
                                VaultCard(
                                    id: vaultCardViewModel.title,
                                    addressText: vaultCardViewModel.addressText,
                                    sealStatus: vaultCardViewModel.sealStatus,
                                    imageName: vaultCardViewModel.imageName,
                                    balanceTitle: vaultCardViewModel.balanceTitle,
                                    balanceAmount: vaultCardViewModel.balanceAmount,
                                    balanceCurrency: vaultCardViewModel.balanceCurrency
                                )
                                .frame(width: 261, height: 197)
                                .snapAlignmentHelper(id: i)
                            case .emptyVault(_):
                                let currIndex = i
                                VaultCardEmpty(id: i)
                                    .frame(width: 261, height: 197)
                                    .snapAlignmentHelper(id: i)
                            }
                        }
                    } eventHandler: { event in
                        handleSnapToScrollEvent(event: event)
                    }
                    
                    Text("EndHomeView")
            }
            if viewStackHandler.navigationState == .onboarding {
                NavigationLink("", destination: OnboardingContainerView(viewModel: OnboardingContainerViewModel()), isActive: .constant(isOnboarding())).hidden()
            }
            if viewStackHandler.navigationState == .takeOwnership {
                NavigationLink("", destination: TakeOwnershipView(viewModel: TakeOwnershipViewModel()), isActive: .constant(isTakeOwnership())).hidden()
            }
            if viewStackHandler.navigationState == .vaultInitialization {
                NavigationLink("", destination: VaultSetupSelectChainView(viewModel: VaultSetupSelectChainViewModel()), isActive: .constant(isVaultInitialization())).hidden()
            }
            }
        }
        .environmentObject(viewStackHandler)
        .onAppear(perform: evaluateNavigation)
    }
    
    func handleSnapToScrollEvent(event: SnapToScrollEvent) {
        switch event {
            case let .didLayout(layoutInfo: layoutInfo):
                print("\(layoutInfo.keys.count) items layed out")
            case let .swipe(index: index):
                print("swiped to index: \(index)")
        }
    }

    func isOnboarding() -> Bool {
        viewStackHandler.navigationState == .onboarding
    }

    func isVaultInitialization() -> Bool {
        viewStackHandler.navigationState == .vaultInitialization
    }
    
    func isTakeOwnership() -> Bool {
        viewStackHandler.navigationState == .takeOwnership
    }

    func isFirstUse() -> Bool {
        // return UserDefaults.standard.bool(forKey: "FirstUse")
        return false
    }
    
    func hasNoOwnership() -> Bool {
        return true
    }

    func isVaultInitialized() -> Bool {
        return UserDefaults.standard.bool(forKey: "VaultInitialized")
    }

    func evaluateNavigation() {
        if isFirstUse() {
            viewStackHandler.navigationState = .onboarding
        } else if hasNoOwnership() {
            viewStackHandler.navigationState = .takeOwnership
        }
        else if !isVaultInitialized() {
            viewStackHandler.navigationState = .vaultInitialization
        } else {
            viewStackHandler.navigationState = .goBackHome
        }
    }
}
