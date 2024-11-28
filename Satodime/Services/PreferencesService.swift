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
    func setVerticalMode(_ verticalMode: Bool)
    func getVerticalMode() -> Bool
}

// MARK: - Service
final class PreferencesService: PPreferencesService {
    private var defaults = UserDefaults()
    
    func getOnboarding() -> Bool {
        print("get onboarding setting \(!defaults.bool(forKey: Constants.Storage.isAppPreviouslyLaunched)) from user defaults!")
        return !defaults.bool(forKey: Constants.Storage.isAppPreviouslyLaunched)
    }
    
    func setOnboarding(_ needToShowOnboarding: Bool) {
        defaults.set(!needToShowOnboarding, forKey: Constants.Storage.isAppPreviouslyLaunched)
        print("saved onboarding setting \(!needToShowOnboarding) in user defaults!")
    }
    
    func getCurrency() -> String {
        print("get currency \(defaults.string(forKey: Constants.Storage.secondCurrency) ?? Constants.Settings.currencies.first!) from user defaults!")
        return defaults.string(forKey: Constants.Storage.secondCurrency) ?? Constants.Settings.currencies.first!
        
    }
    
    func setCurrency(_ currency: String) {
        defaults.set(currency, forKey: Constants.Storage.secondCurrency)
        print("saved new currency \(currency) in user defaults!")
    }
    
    func setVerticalMode(_ verticalMode: Bool) {
        defaults.set(verticalMode, forKey: Constants.Storage.verticalModePreferred)
        print("saved vertical mode \(verticalMode) in user defaults!")
    }
    
    func getVerticalMode() -> Bool {
        print("get vertical mode setting \(defaults.bool(forKey: Constants.Storage.verticalModePreferred)) from user defaults!")
        return defaults.bool(forKey: Constants.Storage.verticalModePreferred)
    }
}

