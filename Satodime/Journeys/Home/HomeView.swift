//
//  HomeView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI

class ViewStackHandler: ObservableObject {
    @Published var navigationState: NavigationState = .goBackHome
}

enum NavigationState {
    case goBackHome
    case onboarding
    case vaultInitialization
}

struct HomeView: View {
    @ObservedObject var viewStackHandler: ViewStackHandler = ViewStackHandler()
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("HomeView")
                if viewStackHandler.navigationState == .onboarding {
                    NavigationLink("", destination: OnboardingContainerView(viewModel: OnboardingContainerViewModel()), isActive: .constant(isOnboarding())).hidden()
                }
                if viewStackHandler.navigationState == .vaultInitialization {
                    NavigationLink("", destination: VaultSetupSelectChainView(viewModel: VaultSetupSelectChainViewModel()), isActive: .constant(isVaultInitialization())).hidden()
                }
            }
        }
        .environmentObject(viewStackHandler)
        .onAppear(perform: evaluateNavigation)
    }

    func isOnboarding() -> Bool {
        viewStackHandler.navigationState == .onboarding
    }

    func isVaultInitialization() -> Bool {
        viewStackHandler.navigationState == .vaultInitialization
    }

    func isFirstUse() -> Bool {
        return UserDefaults.standard.bool(forKey: "FirstUse")
    }

    func isVaultInitialized() -> Bool {
        return UserDefaults.standard.bool(forKey: "VaultInitialized")
    }

    func evaluateNavigation() {
        if isFirstUse() {
            viewStackHandler.navigationState = .onboarding
        } else if !isVaultInitialized() {
            viewStackHandler.navigationState = .vaultInitialization
        } else {
            viewStackHandler.navigationState = .goBackHome
        }
    }
}
