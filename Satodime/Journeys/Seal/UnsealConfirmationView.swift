//
//  UnsealConfirmationView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import SwiftUI

struct UnsealConfirmationView: View {
    // MARK: - Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandler
    @ObservedObject var viewModel: UnsealConfirmationViewModel
    
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
                
                SatoText(text: viewModel.title, style: .title)
                
                Spacer()
                    .frame(height: 49)
                
                SatoText(text: viewModel.subtitle, style: .graySubtitle18)
                
                Spacer()
                    .frame(height: 58)
                
                VaultCard(viewModel: viewModel.vaultCardViewModel, indexPosition: viewModel.indexPosition, useFullWidth: true)
                    .shadow(radius: 10)
                
                Spacer()
                    .frame(height: 62)
                
                SatoText(text: viewModel.confirmationText, style: .graySubtitle)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                Spacer()
                
                SatoButton(staticWidth: 222, text: viewModel.continueButtonTitle, style: .confirm, horizontalPadding: 25) {
                    viewStackHandler.refreshVaults = .refresh
                    viewModel.completeFlow()
                }
                
                Spacer()
                    .frame(height: 29)
                
            }.padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.viewStackHandler = viewStackHandler
        }
    }
}
