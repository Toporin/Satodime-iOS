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
    @Environment(\.openURL) var openURL
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    
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
                        self.preferencesService.setOnboarding(newValue)
                    }
                )
                
                // TODO: add debug level?
                
                Spacer()
                    .frame(height: 33)
                
                SatoButton(text: showLogsButtonTitle, style: .inform, horizontalPadding: Constants.Dimensions.secondButtonPadding) {
                    self.isShowLogs = true
                }
                
                Spacer()
                    .frame(height: 16)
                
                SatoButton(text: String(localized: "sendFeedback"), style: .confirm, horizontalPadding: Constants.Dimensions.secondButtonPadding) {
                    let supportEmail = EmailHelper.SupportEmail()
                    supportEmail.send(openURL: self.openURL)
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            DispatchQueue.main.async {
                self.viewStackHandler.navigationState = .menu
            }
        }) {
            Image("ic_flipback")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: title, style: .lightTitle)
            }
        }
    }// body
}
