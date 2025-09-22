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
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState

    @State var pushConfirmationView: Bool = false
    @State var showNotOwnerAlert: Bool = false
    @State var showUnlockDialog: Bool = false // for Satodime v0.2+ with fixed CVC code
    
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
    
    private func unsealVault(){
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
    }
    
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
                
                SatoButton(text: continueButtonTitle, style: .danger, horizontalPadding: Constants.Dimensions.secondButtonPadding) {
                    
                    if cardState.ownershipStatus == .owner {
                        self.unsealVault()
                    } else {
                        // cardState.ownershipStatus == notOwner or unclaimed
                        if cardState.isFixedCvc {
                            if cardState.ownershipStatus == .unclaimed {
                                self.unsealVault() // onwership will be taken automatically in unseal process
                            }
                            else if cardState.ownershipStatus == .notOwner {
                                self.showUnlockDialog = true // ask user for CVC
                            }
                        } else {
                            self.showNotOwnerAlert = true
                            print("warning: ownership transfer fail: not owner!")
                        }
                    }
                }
                
                Spacer()
                    .frame(height: 29)
                
            }.padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
            
            if (self.pushConfirmationView) {
                NavigationLink("", destination: UnsealConfirmationView(index: index), isActive: .constant(true)).hidden()
            }
            
        } // ZStack
        .overlay(
            ZStack {
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
                } else if showUnlockDialog {
                    UnlockCodeDialog(
                        isPresented: $showUnlockDialog,
                        title: "Enter CVC Code",
                        message: "Please enter the card CVC code to take ownership",
                        onEnter: { cvcString in
                            print("User entered code: \(cvcString)")
                            // convert to bytes
                            let cvcBytes = cvcString.toFixedByteArray(length: 20)
                            // save in defaults
                            var unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockCodeDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                            unlockSecretDict[cardState.authentikeyHex] = cvcBytes
                            UserDefaults.standard.set(unlockSecretDict, forKey: Constants.Storage.unlockCodeDict)
                            // update ownership status
                            // Note: we haven't check cvc validity yet
                            DispatchQueue.main.async {
                                cardState.ownershipStatus = .owner
                            }
                            // unseal card
                            self.unsealVault()
                        },
                        onCancel: {
                            print("User cancelled")
                        }
                    )
                }
            }
        )// overlay
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.viewStackHandler.navigationState = .goBackHome
        }) {
            Image("ic_flipback")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: title, style: .lightTitle)
            }
        }
    }
}
