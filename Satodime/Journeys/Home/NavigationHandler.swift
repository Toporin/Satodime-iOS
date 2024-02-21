//
//  NavigationHandler.swift
//  Satodime
//
//  Created by Lionel Delvaux on 21/02/2024.
//

import Foundation
import SwiftUI

struct NavigationHandlerView: View {
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    @Binding var currentSlotIndex: Int
    @Binding var showTakeOwnershipAlert: Bool
    
    var body: some View {
        Group {
            // MARK: - NAVIGATION
            // NAVIGATION - BASED ON STATE
            // if card is unclaimed, propose to take ownership (only once per card scan)
            if self.cardState.ownershipStatus == .unclaimed {
                NavigationLink("", destination: TakeOwnershipView(showTakeOwnershipAlert: $showTakeOwnershipAlert), isActive: $showTakeOwnershipAlert)
                    .hidden()
            }
            
            // NAVIGATION - CONFIG SCREENS
            if self.viewStackHandler.navigationState == .menu {
                NavigationLink("", destination: MenuView(showTakeOwnershipAlert: $showTakeOwnershipAlert), isActive: .constant(true)).hidden()
            }
            if self.viewStackHandler.navigationState == .onboarding {
                NavigationLink("", destination: OnboardingContainerView(), isActive: .constant(true)).hidden()
            }
            if self.viewStackHandler.navigationState == .cardAuthenticity {
                NavigationLink("", destination: AuthenticView(), isActive: .constant(true)).hidden()
            }
            if self.viewStackHandler.navigationState == .cardInfo {
                NavigationLink("", destination: CardInfoView(), isActive: .constant(true)).hidden()
            }
            if self.viewStackHandler.navigationState == .settings {
                NavigationLink("", destination: SettingsView(), isActive: .constant(true)).hidden()
            }
            if self.viewStackHandler.navigationState == .addFunds {
                NavigationLink("", destination: AddFundsViewNew(index: currentSlotIndex), isActive: .constant(true)).hidden()
            }
            
            // NAVIGATION - CARD ACTION SCREENS
            if self.viewStackHandler.navigationState == .takeOwnership {
                NavigationLink("", destination: TakeOwnershipView(showTakeOwnershipAlert: $showTakeOwnershipAlert), isActive: .constant(true)).hidden()
            }
            if self.viewStackHandler.navigationState == .vaultInitialization {
                NavigationLink("", destination: VaultSetupSelectChainView(index: currentSlotIndex), isActive: .constant(true)).hidden()
            }
            if self.viewStackHandler.navigationState == .vaultSetupCongrats {
                NavigationLink("", destination: VaultSetupCongratsView(index: currentSlotIndex), isActive: .constant(true)).hidden()
            }
            if self.viewStackHandler.navigationState == .unseal {
                NavigationLink("", destination: UnsealView(index: currentSlotIndex), isActive: .constant(true)).hidden()
            }
            if self.viewStackHandler.navigationState == .privateKey {
                NavigationLink("", destination: ShowPrivateKeyMenuView(index: currentSlotIndex), isActive: .constant(true)).hidden()
            }
            if self.viewStackHandler.navigationState == .reset {
                NavigationLink("", destination: ResetView(index: currentSlotIndex), isActive: .constant(true)).hidden()
            }
        }
    }
}
