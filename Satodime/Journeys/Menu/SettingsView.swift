//
//  SettingsView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    @State var selectedValue: String = ""
    @State var showingSheet = false
    @State var starterIntroIsOn: Bool = false
    @State var isShowLogs: Bool = false
    
    let preferencesService: PPreferencesService = PreferencesService()
    
    // MARK: - Literals
    let title = "settings"
    let currencyTitle = "currency"
    let starterIntroTitle = "starterIntro"
    let showLogsButtonTitle = String(localized: "showLogs")
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 47)
                
                Image("il_settings")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 212)
                
                Spacer()
                    .frame(height: 47)
                
                SettingsDropdown(
                    title: currencyTitle,
                    backgroundColor: Constants.Colors.blueMenuButton,
                    selectedValue: $selectedValue,
                    action: { showingSheet.toggle() }
                )
                
                Spacer()
                    .frame(height: 22)
                
                SettingsToggle(
                    title: starterIntroTitle,
                    backgroundColor: Constants.Colors.blueMenuButton,
                    isOn: $starterIntroIsOn,
                    onToggle: { newValue in
                        //setOnboarding(setOnboarding: newValue)
                        self.preferencesService.setOnboarding(newValue)
                    }
                )
                
                // TODO: add debug level?
                
                Spacer()
                    .frame(height: 33)
                
                SatoButton(staticWidth: 134, text: showLogsButtonTitle, style: .inform) {
                    self.isShowLogs = true
                }
                
                Spacer()
                
                NavigationLink(destination: ShowLogs(), isActive: $isShowLogs) {
                    EmptyView()
                }
            }// VStack
            .padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
            .sheet(isPresented: $showingSheet) {
                SelectionSheet(isPresented: $showingSheet, choices: Constants.Settings.currencies) { selected in
                    selectedValue = selected
                    self.preferencesService.setCurrency(selected)
                }
            }
        } //ZStack
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: title, style: .lightTitle)
            }
        }
    }// body
}
