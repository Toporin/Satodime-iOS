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
    @ObservedObject var viewModel: SettingsViewModel
    
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
                    title: viewModel.currencyTitle,
                    backgroundColor: Constants.Colors.blueMenuButton,
                    selectedValue: $viewModel.selectedValue,
                    action: { viewModel.showingSheet.toggle() }
                )
                
                Spacer()
                    .frame(height: 22)
                
                SettingsToggle(
                    title: viewModel.starterIntroTitle,
                    backgroundColor: Constants.Colors.blueMenuButton,
                    isOn: $viewModel.starterIntroIsOn,
                    onToggle: { newValue in
                        viewModel.setOnboarding(setOnboarding: newValue)
                    }
                )
                
                Spacer()
                    .frame(height: 33)
                
                SatoButton(staticWidth: 134, text: viewModel.showLogsButtonTitle, style: .inform) {
                    viewModel.gotoShowLogs()
                }
                
                Spacer()
                
                NavigationLink(destination: ShowLogs(), isActive: $viewModel.isShowLogs) {
                    EmptyView()
                }
            }
            .padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
            .sheet(isPresented: $viewModel.showingSheet) {
                SelectionSheet(isPresented: $viewModel.showingSheet, choices: Constants.Settings.currencies) { selected in
                    viewModel.selectedValue = selected
                    viewModel.setCurrency(currency: selected)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: viewModel.title, style: .lightTitle)
            }
        }
    }
}
