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
                    .frame(height: 66)
                
                SatoText(text: "", style: .lightSubtitle)
                
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
                SatoText(text: viewModel.title, style: .title)
            }
        }
    }
}
