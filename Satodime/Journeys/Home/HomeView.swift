//
//  HomeView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI
import SnapToScroll
import Combine
import Toasty

class AppState: ObservableObject {
    @Published var isFirstUse: Bool {
        didSet {
            PreferencesService().setOnboarding(isFirstUse)
        }
    }
    @Published var currency: String {
        didSet {
            PreferencesService().setCurrency(currency)
        }
    }
    
    init() {
        self.isFirstUse = PreferencesService().getOnboarding()
        self.currency = PreferencesService().getCurrency()
    }
}


struct HomeView: View {
    // MARK: - Properties
    let reviewRequestService = ReviewRequestService()
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var nftPreviewHandler: NftPreviewHandler
    @EnvironmentObject var infoToastMessageHandler: InfoToastMessageHandler
    @EnvironmentObject var appState: AppState
    // let user disable specific alert prompts for the current app session
    @State var showNotOwnerAlert: Bool = true
    @State var showNotAuthenticAlert: Bool = true
    @State var showCardNeedsToBeScannedAlert: Bool = false
    // show the TakeOwnershipView if card is unclaimed, this is transmitted with CardInfoView
    @State var showTakeOwnershipAlert: Bool = true
    @State var showNoNetworkAlert: Bool = false
    let preferencesService: PPreferencesService = PreferencesService()
    // @State var isVerticalModeEnabled: Bool = false
    @StateObject var viewModeHandler = ViewModeHandler()
    @State var isRefreshingCard: Bool = false
    // current slot shown to user
    @State private var currentSlotIndex: Int = 0
    @State var refresherId: UUID = UUID()
    
    // MARK: Body
    var body: some View {
        NavigationView {
                ZStack {
                    Constants.Colors.viewBackground
                        .ignoresSafeArea()
                    
                    if self.cardState.hasReadCard() {
                        VStack {
                            Image(self.gradientToDisplay())
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height*0.5)
                                .clipped()
                                .ignoresSafeArea()
                            Spacer()
                        }
                    }
                    
                    VStack {
                        
                        HeaderView(showNotOwnerAlert: self.$showNotOwnerAlert,
                                   showNotAuthenticAlert: self.$showNotAuthenticAlert,
                                   showCardNeedsToBeScannedAlert: self.$showCardNeedsToBeScannedAlert,
                                   showTakeOwnershipAlert: self.$showTakeOwnershipAlert,
                                   viewModeHandler: self.viewModeHandler,
                                   currentSlotIndex: self.$currentSlotIndex,
                                   isRefreshingCard: self.$isRefreshingCard,
                                   showNoNetworkAlert: self.$showNoNetworkAlert)
                        
                        Spacer()
                            .frame(height: 16)
                        
                        if self.viewModeHandler.isVerticalModeEnabled {
                            VerticalCardsView(currentSlotIndex: self.$currentSlotIndex,
                                              showNotOwnerAlert: self.$showNotOwnerAlert)
                                .onReceive(Just(self.viewModeHandler.isVerticalModeEnabled)) { value in
                                    currentSlotIndex = 0 // We need to reset the current slot to 0 when switching views
                                }
                        } else {
                            HorizontalCardsView(currentSlotIndex: self.$currentSlotIndex, showNotOwnerAlert: self.$showNotOwnerAlert)
                        }

                        Spacer()
                    }
                    .id(viewModeHandler)
                    .toast(isPresenting: $showNoNetworkAlert, duration: 8.0) {
                        ToastHUD(type: .error(.orange), title: String(localized: "noNetworkAlertTitle"), subtitle: String(localized: "noNetworkAlertMessage"))
                    }
                    
                    NavigationHandlerView(currentSlotIndex: self.$currentSlotIndex,
                                          showTakeOwnershipAlert: self.$showTakeOwnershipAlert)
                        .environmentObject(viewStackHandler)
                        .environmentObject(cardState)
                        .environmentObject(appState)

                }
                .id(refresherId)
                .overlay(
                    Group {
                        // Show scan button overlay when no card has been scanned
                        if !self.isRefreshingCard {
                            EmptyScanStateOverlay(showNotOwnerAlert: self.$showNotOwnerAlert,
                                                  showNotAuthenticAlert: self.$showNotAuthenticAlert,
                                                  showTakeOwnershipAlert: self.$showTakeOwnershipAlert,
                                                  showNoNetworkAlert: self.$showNoNetworkAlert)
                        }
                        
                        // Use AlertsHandler to show one or more alerts when needed
                        AlertsHandlerView(
                            showNotOwnerAlert: self.$showNotOwnerAlert,
                            showNotAuthenticAlert: self.$showNotAuthenticAlert,
                            showCardNeedsToBeScannedAlert: self.$showCardNeedsToBeScannedAlert
                            )
                            .environmentObject(cardState)
                            .environmentObject(viewStackHandler)
                            .environmentObject(nftPreviewHandler)
                    }
                )
        }
        .onAppear {
            if isFirstUse() {
                navigateTo(destination: .onboarding)
            }
            reviewRequestService.appLaunched()
        }
        .onChange(of: appState.isFirstUse) { newValue in
            if newValue {
                navigateTo(destination: .onboarding)
            }
        }
        .onChange(of: appState.currency) { currency in
            self.refresherId = UUID()
            guard !cardState.vaultArray.isEmpty else { return }
            var bufferVaultsArray: [VaultItem] = []
            for vault in cardState.vaultArray {
                var bufferVaultItem = VaultItem(index: vault.index, keyslotStatus: vault.keyslotStatus)
                bufferVaultItem.address = vault.address
                bufferVaultItem.balance = vault.balance
                bufferVaultItem.selectedSecondCurrency = currency
                bufferVaultItem.coinValueInSecondCurrency = 0.0
                bufferVaultsArray.append(bufferVaultItem)
            }
            cardState.vaultArray = bufferVaultsArray
            currentSlotIndex = 0
            for index in 0..<cardState.vaultArray.count-1 {
                print("*** Index ** is \(index)")
                Task {
                    await cardState.fetchDataFromWeb(index: index)
                }
            }
        }
        .toast(isPresenting: $infoToastMessageHandler.shouldShowCopiedToClipboardMessage, duration: 2.0) {
            ToastHUD(type: .complete(Constants.Colors.confirmButtonBackground), title: nil, subtitle: String(localized: "copiedToClipboardAlertMessage"))
        }
    }
    
    // MARK: - Helpers
    
    func navigateTo(destination: NavigationState) {
        DispatchQueue.main.async {
            self.viewStackHandler.navigationState = destination
        }
    }
    
    func isFirstUse() -> Bool {
        let result = UserDefaults.standard.bool(forKey: Constants.Storage.isAppPreviouslyLaunched) == false
        return result
    }
    
    func gradientToDisplay() -> String {
        if cardState.vaultArray.isEmpty { return "" }
        if cardState.vaultArray[currentSlotIndex].getStatus() == .uninitialized {return ""}
        
        switch currentSlotIndex%3 {
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
    
}
