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
    @Published var isShowLogs: Bool = false
    
    // MARK: - Literals
    let title = "settings"
    let currencyTitle = "currency"
    let starterIntroTitle = "starterIntro"
    let showLogsButtonTitle = "showLogs"
    
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
    
    func gotoShowLogs() {
        self.isShowLogs = true
    }
}
