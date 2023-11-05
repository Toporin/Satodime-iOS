//
//  ResetView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import SwiftUI

struct ResetView: View {
    // MARK: - Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandler
    @ObservedObject var viewModel: ResetViewModel
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.errorViewBackground
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 37)
                
                SatoText(text: viewModel.subtitle, style: .lightTitle)
                
                Spacer()
                    .frame(height: 29)
                
                VaultCard(viewModel: viewModel.vaultCardViewModel, indexPosition: viewModel.indexPosition, useFullWidth: true)
                    .shadow(radius: 10)
                
                Spacer()
                    .frame(height: 27)
                
                SatoText(text: viewModel.resetText, style: .graySubtitle)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                
                Spacer()
                    .frame(height: 24)
                
                Rectangle()
                    .frame(width: 108, height: 2)
                    .foregroundColor(Constants.Colors.separator)
                
                Spacer()
                    .frame(height: 20)
                
                SatoText(text: viewModel.informationText, style: .graySubtitle)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                Spacer()
                    .frame(height: 27)
                
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Spacer()
                    SatoToggle(isOn: $viewModel.hasUserConfirmedTerms, label: viewModel.confirmationText)
                    Spacer()
                })
                
                Spacer()
                
                SatoButton(staticWidth: 293, text: viewModel.continueButtonTitle, style: .danger, action:  {
                    if viewModel.hasUserConfirmedTerms {
                        viewModel.reset()
                    }
                }, isEnabled: $viewModel.hasUserConfirmedTerms.wrappedValue)
                
                Spacer()
                    .frame(height: 29)
                
            }.padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
            
            NavigationLink(
                destination: ResetConfirmationView(viewModel: ResetConfirmationViewModel(vaultCardViewModel: viewModel.vaultCardViewModel, indexPosition: viewModel.indexPosition)),
                isActive: $viewModel.pushConfirmationView
            ) {
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.viewModel.navigateTo(destination: .goBackHome)
        }) {
            Image("ic_flipback")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: viewModel.title, style: .lightTitle)
            }
        }
        .onAppear {
            viewModel.viewStackHandler = viewStackHandler
        }
    }
}
