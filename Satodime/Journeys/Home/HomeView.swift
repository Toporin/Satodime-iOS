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

struct HomeView: View {
    // MARK: - Properties
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    // let user disable specific alert prompts for the current app session
    @State var showNotOwnerAlert: Bool = true
    @State var showNotAuthenticAlert: Bool = true
    @State var showCardNeedsToBeScannedAlert: Bool = false
    // show the TakeOwnershipView if card is unclaimed, this is transmitted with CardInfoView
    @State var showTakeOwnershipAlert: Bool = true
    @State var isVerticalModeEnabled: Bool = false
    @State var isRefreshingCard: Bool = false
    
    // current slot shown to user
    @State private var currentSlotIndex: Int = 0
    
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
                                   isVerticalModeEnabled: self.$isVerticalModeEnabled,
                                   currentSlotIndex: self.$currentSlotIndex,
                                   isRefreshingCard: self.$isRefreshingCard)
                        
                        Spacer()
                            .frame(height: 16)
                        
                        if self.isVerticalModeEnabled {
                            VerticalCardsView(currentSlotIndex: self.$currentSlotIndex,
                                              showNotOwnerAlert: self.$showNotOwnerAlert)
                                .onReceive(Just(isVerticalModeEnabled)) { value in
                                    currentSlotIndex = 0 // We need to reset the current slot to 0 when switching views
                                }
                        } else {
                            HorizontalCardsView(currentSlotIndex: self.$currentSlotIndex, showNotOwnerAlert: self.$showNotOwnerAlert)
                        }

                        Spacer()
                    }
                    
                    NavigationHandlerView(currentSlotIndex: $currentSlotIndex,
                                          showTakeOwnershipAlert: $showTakeOwnershipAlert)
                        .environmentObject(viewStackHandler)
                        .environmentObject(cardState)

                }
                .overlay(
                    Group {
                        // Show scan button overlay when no card has been scanned
                        if !self.isRefreshingCard {
                            EmptyScanStateOverlay(showNotOwnerAlert: self.$showNotOwnerAlert,
                                                  showNotAuthenticAlert: self.$showNotAuthenticAlert,
                                                  showTakeOwnershipAlert: self.$showTakeOwnershipAlert)
                        }
                        
                        // Use AlertsHandler to show one or more alerts when needed
                        AlertsHandlerView(
                                showNotOwnerAlert: $showNotOwnerAlert,
                                showNotAuthenticAlert: $showNotAuthenticAlert,
                                showCardNeedsToBeScannedAlert: $showCardNeedsToBeScannedAlert
                            )
                            .environmentObject(cardState)
                            .environmentObject(viewStackHandler)
                    }
                )
        }
        .onAppear {
            if isFirstUse() {
                navigateTo(destination: .onboarding)
            }
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
