//
//  VaultSetupCongratsView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 02/10/2023.
//

import Foundation
import SwiftUI

struct VaultSetupCongratsView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: VaultSetupCongratsViewModel
    @EnvironmentObject var viewStackHandler: ViewStackHandler
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                SatoText(text: viewModel.title, style: .viewTitle)
                
                Spacer()
                    .frame(height: 37)
                
                SatoText(text: viewModel.subtitle, style: .graySubtitle)
                
                Spacer()
                    .frame(height: 25)
                
                ZStack {
                    Image("il_vault")
                        .resizable()
                        .frame(width: 225, height: 225)
                        .aspectRatio(contentMode: .fit)
                        .overlay(
                            ZStack {
                                Circle()
                                    .fill(viewModel.selectedCrypto.color)
                                    .frame(width: 66, height: 66)
                                    .padding(16)

                                Image(viewModel.selectedCrypto.icon)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 66, height: 66)
                            .position(CGPoint(x: 8, y: 210))
                        )
                }
                
                Spacer()
                
                SatoText(text: viewModel.informationText, style: .graySubtitle)
                
                Spacer()
                
                SatoButton(staticWidth: 222, text: viewModel.continueButtonTitle, style: .confirm) {
                    viewStackHandler.navigationState = .goBackHome
                }
                
                Spacer()
                    .frame(height: 29)
            }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
        }
        .navigationBarHidden(true)
    }
}
