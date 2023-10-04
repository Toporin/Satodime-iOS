//
//  SatodimeApp.swift
//  Satodime for iOS
//
//  Created by Satochip on 21/01/2023.
//  Copyright © 2023 Satochip S.R.L.
//
import SwiftUI

@main
struct SatodimeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage(Constants.Storage.isFirstUse) var isFirstUse = true
    
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel())
            /*if isFirstUse {
                OnboardingContainerView(viewModel: OnboardingContainerViewModel())
                // VaultSetupSelectChainView(viewModel: VaultSetupSelectChainViewModel())
            } else {
                HomeView(viewModel: HomeViewModel())
            }*/
        }
    }
}
