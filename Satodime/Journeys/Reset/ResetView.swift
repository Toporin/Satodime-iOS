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
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    
    @State var pushConfirmationView: Bool = false
    @State var hasUserConfirmedTerms = false
    @State var showNotOwnerAlert: Bool = false
    @State var showUnlockDialog: Bool = false // for Satodime v0.2+ with fixed CVC code
    
    let index: Int
    
    // MARK: - Literals
    let title = "warning"
    let subtitle = "youAreAboutToReset"
    let resetText = "resettingThisCryptoVaultWill"
    let informationText = "afterThatYouWillBeAbleTo"
    let confirmationText = "iConfirmThatBackup"
    let continueButtonTitle = String(localized: "resetTheVault")
    
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
    
    private func resetVault(){
        cardState.resetVault(
            cardAuthentikeyHex: cardState.authentikeyHex,
            index: index,
            onSuccess: {
                print("SUCCESS: reset vault \(index)!")
                DispatchQueue.main.async {
                    self.pushConfirmationView = true
                }
            },
            onFail: {
                print("ERROR: failed to reset vault!")
            }
        )
    }
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.errorViewBackground
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
                
                SatoText(text: resetText, style: .graySubtitle)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                
                Spacer()
                    .frame(height: 24)
                
                Rectangle()
                    .frame(width: 108, height: 2)
                    .foregroundColor(Constants.Colors.separator)
                
                Spacer()
                    .frame(height: 20)
                
                SatoText(text: informationText, style: .graySubtitle)
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                
                Spacer()
                    .frame(height: 27)
                
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    SatoToggle(isOn: $hasUserConfirmedTerms, label: confirmationText)
                })
                
                Spacer()
                
                SatoButton(text: continueButtonTitle, style: .danger, horizontalPadding: Constants.Dimensions.secondButtonPadding, action:  {
                    
                    if cardState.ownershipStatus == .owner {
                        self.resetVault()
                    } else {
                        // cardState.ownershipStatus == notOwner or unclaimed
                        if cardState.isFixedCvc {
                            if cardState.ownershipStatus == .unclaimed {
                                // no need to ask CVC, onwership will be taken automatically in unseal process
                                self.resetVault()
                            }
                            else if cardState.ownershipStatus == .notOwner {
                                // ask user for CVC, then proceed
                                self.showUnlockDialog = true
                            }
                        } else {
                            self.showNotOwnerAlert = true
                        }
                    }
                    
                }, isEnabled: $hasUserConfirmedTerms.wrappedValue)
                
                Spacer()
                    .frame(height: 29)
                
            }.padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
            
            if (self.pushConfirmationView){
                NavigationLink("", destination: ResetConfirmationView(index: index), isActive: .constant(true)).hidden()
            }
            
        }//ZStack
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
                } else if showUnlockDialog {
                    UnlockCodeDialog(
                        isPresented: $showUnlockDialog,
                        title: "Enter CVC Code",
                        message: "Please enter the card CVC code to proceed",
                        onEnter: { cvcString in
                            print("User entered code: \(cvcString)")
                            // convert to bytes
                            let cvcBytes = cvcString.toFixedByteArray(length: 20)
                            // save in defaults
                            var unlockCodeDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockCodeDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                            unlockCodeDict[cardState.authentikeyHex] = cvcBytes
                            UserDefaults.standard.set(unlockCodeDict, forKey: Constants.Storage.unlockCodeDict)
                            // update ownership status
                            // Note: we haven't check cvc validity yet
                            DispatchQueue.main.async {
                                cardState.ownershipStatus = .owner
                            }
                            // reset
                            self.resetVault()
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
            DispatchQueue.main.async {
                self.viewStackHandler.navigationState = .goBackHome
            }
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
