//
//  UnsealView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import SwiftUI

struct UnsealView: View {
    // MARK: - Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandler
    @ObservedObject var viewModel: UnsealViewModel
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            RadialGradient(gradient: Gradient(colors: [Constants.Colors.errorViewBackground, Constants.Colors.errorViewBackground.opacity(0)]), center: .center, startRadius: 10, endRadius: 280)
                            .position(x: 120, y: 340)
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
                
                SatoText(text: viewModel.unsealText, style: .graySubtitle)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                Spacer()
                    .frame(height: 24)
                
                Rectangle()
                    .frame(width: 108, height: 2)
                    .foregroundColor(Constants.Colors.separator)
                
                Spacer()
                    .frame(height: 20)
                
                SatoText(text: viewModel.transferText, style: .graySubtitle)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                Spacer()
                    .frame(height: 27)
                
                SatoText(text: viewModel.informationText, style: .subtitle)
                    .frame(maxWidth: .infinity, minHeight: 61, maxHeight: 61)
                    .background(Constants.Colors.cellBackground)
                    .cornerRadius(20)
                                    
                Spacer()
                
                SatoButton(staticWidth: 146, text: viewModel.continueButtonTitle, style: .danger) {
                    viewModel.unsealSlot()
                }
                
                Spacer()
                    .frame(height: 29)
                
            }.padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
            
            NavigationLink(
                destination: UnsealConfirmationView(viewModel: UnsealConfirmationViewModel(vaultCardViewModel: viewModel.vaultCardViewModel, indexPosition: viewModel.indexPosition)),
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
