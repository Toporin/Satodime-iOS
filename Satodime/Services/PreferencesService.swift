//
//  PreferencesService.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation

// MARK: - Protocol
protocol PPreferencesService {
    func getCurrency() -> String
    func setCurrency(_ currency: String)
    func getOnboarding() -> Bool
    func setOnboarding(_ needToShowOnboarding: Bool)
}

// MARK: - Service
final class PreferencesService: PPreferencesService {
    private var defaults = UserDefaults()
    
    func getOnboarding() -> Bool {
        return !defaults.bool(forKey: Constants.Storage.isAppPreviouslyLaunched)
    }
    
    func setOnboarding(_ needToShowOnboarding: Bool) {
        defaults.set(!needToShowOnboarding, forKey: Constants.Storage.isAppPreviouslyLaunched)
    }
    
    func getCurrency() -> String {
        return defaults.string(forKey: Constants.Storage.secondCurrency) ?? Constants.Settings.currencies.first!
    }
    
    func setCurrency(_ currency: String) {
        defaults.set(currency, forKey: Constants.Storage.secondCurrency)
    }
}

