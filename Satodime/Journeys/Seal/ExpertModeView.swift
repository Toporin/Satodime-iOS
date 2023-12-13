//
//  ExpertModeView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 16/10/2023.
//

import Foundation
import SwiftUI

// TODO: remove
struct ExpertModeView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: ExpertModeViewModel
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 37)
                                
                InfoBox(text: viewModel.informationText, fullWidth: true)
                
                Spacer()
                    .frame(height: 61)
                
                HStack {
                    SatoText(text: viewModel.networkChoiceSystem, style: .subtitle, alignment: .leading)
                    Spacer()
                }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                Spacer()
                    .frame(height: 15)
                
                Rectangle()
                    .frame(width: .infinity, height: 2)
                    .foregroundColor(Constants.Colors.separator)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                SatoChoiceSelector(selectedItem: $viewModel.selectedNetwork, items: NetworkMode.allCases)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                Rectangle()
                    .frame(width: .infinity, height: 2)
                    .foregroundColor(Constants.Colors.separator)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                Spacer()
                    .frame(height: 28)
                
                HStack {
                    SatoText(text: viewModel.entropyTitle, style: .subtitle, alignment: .leading)
                    Spacer()
                }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                Spacer()
                    .frame(height: 15)
                
                SatoInputText(text: $viewModel.entropy, placeholder: "")
                
                Spacer()
                
//                NavigationLink(
//                    destination: VaultSetupCongratsView(viewModel: VaultSetupCongratsViewModel(selectedCrypto: viewModel.selectedCrypto)),
//                    isActive: $viewModel.isNextViewActive
//                ) {
//                    EmptyView()
//                }
                
                SatoButton(staticWidth: 177, text: viewModel.continueButtonTitle, style: .confirm) {
                    viewModel.sealSlot()
                }
                
                Spacer()
                    .frame(height: 29)
                
            }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: viewModel.title, style: .lightTitle)
            }
        }
        .onTapGesture {
            dismissKeyboard()
        }
    }
}
