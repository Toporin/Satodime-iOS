//
//  VaultSetupCreateView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 02/10/2023.
//

import Foundation
import SwiftUI

struct VaultSetupCreateView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: VaultSetupCreateViewModel
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 37)
                
                SatoText(text: viewModel.subtitle, style: .graySubtitle)
                
                Spacer()
                    .frame(height: 37)
                
                SatoText(text: viewModel.selectedCrypto.shortIdentifier, style: .subtitleBold)
                
                Spacer()
                    .frame(height: 16)
                
                ZStack {
                    Circle()
                        .fill(viewModel.selectedCrypto.color)
                        .frame(width: 100, height: 100)
                        .padding(10)
                    
                    Image(viewModel.selectedCrypto.icon)
                        .frame(width: 100, height: 100)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                }
                
                Spacer()
                    .frame(height: 65)
                
                SatoText(text: viewModel.informationText, style: .graySubtitle)
                    .frame(maxWidth: .infinity, minHeight: 91)
                    .background(Constants.Colors.cellBackground)
                    .cornerRadius(20)
                
                Spacer()
                    .frame(height: 64)
                
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Spacer()
                    SatoToggle(isOn: $viewModel.isExpertModeActivated, label: viewModel.activateExpertModeText)
                    Spacer()
                })
                
                Spacer()
                
                NavigationLink(
                    destination: ExpertModeView(viewModel: ExpertModeViewModel(cardService: CardService(), selectedCrypto: viewModel.selectedCrypto, index: viewModel.index, vaultCards: viewModel.vaultCards)),
                    isActive: $viewModel.isExpertModeViewActive
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: VaultSetupCongratsView(viewModel: VaultSetupCongratsViewModel(selectedCrypto: viewModel.selectedCrypto)),
                    isActive: $viewModel.isNextViewActive
                ) {
                    EmptyView()
                }
                
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
                SatoText(text: viewModel.title, style: .viewTitle)
            }
        }
    }
}
