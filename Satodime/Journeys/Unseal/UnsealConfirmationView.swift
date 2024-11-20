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
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    
    let index: Int
    
    // MARK: - Literals
    let title = "congrats"
    let subtitle = "vaultSuccessfullyUnseal"
    let confirmationText = "youCanNowViewThePrivateKey"
    let continueButtonTitle = String(localized: "showThePrivateKey")
    
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
                
                SatoText(text: title, style: .title)
                
                Spacer()
                    .frame(height: 49)
                
                SatoText(text: subtitle, style: .graySubtitle18)
                
                Spacer()
                    .frame(height: 58)
                
                VaultCardNew(index: UInt8(index), action: {}, useFullWidth: true)
                    .shadow(radius: 10)
                
                Spacer()
                    .frame(height: 62)
                
                SatoText(text: confirmationText, style: .graySubtitle)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                Spacer()
                
                SatoButton(text: continueButtonTitle, style: .confirm, horizontalPadding: Constants.Dimensions.secondButtonPadding) {
                    self.viewStackHandler.navigationState = .privateKey
                }
                
                Spacer()
                    .frame(height: 29)
                
            }.padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            //self.viewModel.navigateTo(destination: .goBackHome)
            self.viewStackHandler.navigationState = .goBackHome
        }) {
            Image("ic_flipback")
        })
    }
}
