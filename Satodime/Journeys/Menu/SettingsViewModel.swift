//
//  SettingsViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation

final class SettingsViewModel: BaseViewModel {
    // MARK: - Properties
    let preferencesService: PPreferencesService
    @Published var selectedValue: String = ""
    @Published var showingSheet = false
    @Published var starterIntroIsOn: Bool = false
    
    // MARK: - Literals
    let title = "Settings"
    let currencyTitle = "Currency"
    let starterIntroTitle = "Starter intro"
    let showLogsButtonTitle = "Show logs"
    
    init(preferencesService: PPreferencesService){
        self.preferencesService = preferencesService
        self.selectedValue = self.preferencesService.getCurrency()
        self.starterIntroIsOn = self.preferencesService.getOnboarding()
    }
    
    func setOnboarding(setOnboarding: Bool) {
        self.preferencesService.setOnboarding(setOnboarding)
    }
    
    func setCurrency(currency: String){
        self.preferencesService.setCurrency(currency)
    }
}
