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
    //@EnvironmentObject var viewStackHandler: ViewStackHandler
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    //@ObservedObject var viewModel: UnsealViewModel
    //let cardService: PCardService
    //@Published var vaultCardViewModel: VaultCardViewModel
    @State var pushConfirmationView: Bool = false
    @State var showNotOwnerAlert: Bool = false
    
    let index: Int
    
    // MARK: - Literals
    let title = "warning"
    let subtitle = "youAreAboutToUnseal"
    let unsealText = "unsealingThisCryptoVaultWillReveal"
    let transferText = "youCanThenTransferTheEntireBalance"
    let informationText = "thisActionIsIrreversible"
    let continueButtonTitle = String(localized: "unseal")
    
    let notOwnerAlert = SatoAlert(
        title: "ownership",
        message: "ownershipText",
        buttonTitle: String(localized:"moreInfo"),
        buttonAction: {
            guard let url = URL(string: "https://satochip.io/satodime-ownership-explained/") else {
                print("Invalid URL")
                return
            }
            UIApplication.shared.open(url)
        }
    )
    
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
                
                SatoText(text: subtitle, style: .lightTitleSmall)
                    .lineLimit(nil)
                
                Spacer()
                    .frame(height: 29)
                
                //VaultCard(viewModel: viewModel.vaultCardViewModel, indexPosition: viewModel.indexPosition, useFullWidth: true)
                VaultCardNew(index: UInt8(index), action: {}, useFullWidth: true)
                    .shadow(radius: 10)
                
                Spacer()
                    .frame(height: 27)
                
                SatoText(text: unsealText, style: .graySubtitle)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                Spacer()
                    .frame(height: 24)
                
                Rectangle()
                    .frame(width: 108, height: 2)
                    .foregroundColor(Constants.Colors.separator)
                
                Spacer()
                    .frame(height: 20)
                
                SatoText(text: transferText, style: .graySubtitle)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                Spacer()
                    .frame(height: 27)
                
                SatoText(text: informationText, style: .subtitle)
                    .frame(maxWidth: .infinity, minHeight: 61, maxHeight: 61)
                    .background(Constants.Colors.cellBackground)
                    .cornerRadius(20)
                                    
                Spacer()
                
                SatoButton(staticWidth: 146, text: continueButtonTitle, style: .danger) {
                    
                    if cardState.ownershipStatus == .owner {
                        
                        cardState.unsealVault(
                            cardAuthentikeyHex: cardState.authentikeyHex,
                            index: index,
                            onSuccess: {
                                DispatchQueue.main.async {
                                    self.pushConfirmationView = true
                                }
                            },
                            onFail: {
                                print("Error: Failed to unseal slot!!")
                            }
                        )
                    } else {
                        self.showNotOwnerAlert = true
                        //print("warning: ownership transfer fail: not owner!")
                    }
                }
                
                Spacer()
                    .frame(height: 29)
                
            }.padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
            
//            NavigationLink(
//                destination: UnsealConfirmationView(index: index),
//                isActive: $pushConfirmationView
//            ) {
//                EmptyView()
//            }
            if (self.pushConfirmationView) {
                NavigationLink("", destination: UnsealConfirmationView(index: index), isActive: .constant(true)).hidden()
            }
            
        } // ZStack
        .overlay(
            Group {
                // Alert if user is not owner
                if showNotOwnerAlert {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showNotOwnerAlert = false
                            }
                        
                        SatoAlertView(isPresented: $showNotOwnerAlert, alert: notOwnerAlert)
                            .padding([.leading, .trailing], 24)
                    }
                }
            }
        )// overlay
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            //self.viewModel.navigateTo(destination: .goBackHome)
            self.viewStackHandler.navigationState = .goBackHome
        }) {
            Image("ic_flipback")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: title, style: .lightTitle)
            }
        }
//        .onAppear {
//            viewModel.viewStackHandler = viewStackHandler
//        }
    }
}
