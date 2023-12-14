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
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    
    var index: Int
    
    // MARK: - Literals
    let title = "congrats"
    let subtitle = "yourVaultsHasBeenCreated"
    let informationText = "rememberPrivateKeys"
    let continueButtonTitle = String(localized: "showMyVault")
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                SatoText(text: title, style: .viewTitle)
                
                Spacer()
                    .frame(height: 37)
                
                SatoText(text: subtitle, style: .graySubtitle)
                
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
                                    .fill(cardState.vaultArray[index].coinMeta.color)
                                    .frame(width: 66, height: 66)
                                    .padding(16)

                                Image(cardState.vaultArray[index].coinMeta.icon) //TODO: DEBUG!! //Image(selectedCrypto.icon)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 66, height: 66)
                            .position(CGPoint(x: 8, y: 210))
                        )
                }
                
                Spacer()
                
                SatoText(text: informationText, style: .graySubtitle)
                
                Spacer()
                
                SatoButton(staticWidth: 222, text: continueButtonTitle, style: .confirm) {
                    self.viewStackHandler.navigationState = .goBackHome
                }
                
                Spacer()
                    .frame(height: 29)
            }// VStack
            .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
        }// ZStack
        .navigationBarHidden(true)
    }// body
}
 
