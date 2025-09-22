//
//  ShowPrivateKeyMenuView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import SwiftUI

enum ShowPrivateKeyMode: String, Hashable {
    case legacy = "showPrivateKeyLegacy"
    case wif = "showPrivateKeyWIF"
    case entropy = "showEntropy"
}

struct ShowPrivateKeyMenuView: View {
    // MARK: - Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    @State var showNotOwnerAlert: Bool = false
    @State var showUnlockDialog: Bool = false // for Satodime v0.2+ with fixed CVC code
        
    @State var selectedMode: ShowPrivateKeyMode = .legacy //TODO: need to be @State?
    @State var isKeyViewPresented = false
    
    let index: Int
    
    // MARK: - Literals
    let title = "showPrivateKey"
    let keyDisplayOptions: [ShowPrivateKeyMode] = [.legacy, .wif, .entropy]
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
    
    private func showPrivateKey(){
        cardState.getPrivateKey(
            cardAuthentikeyHex: cardState.authentikeyHex,
            index: index,
            onSuccess: {privkeyInfo in
                DispatchQueue.main.async {
                    self.cardState.vaultArray[index].privkey = privkeyInfo.privkey
                    self.cardState.vaultArray[index].entropy = privkeyInfo.entropy
                    //self.selectedMode = mode
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isKeyViewPresented = true // without delay, view is only shown temporarily
                }
            },
            onFail: {
                print("error privkeyResult: failed to recover privkey (are you owner??")
            }
        )
    }
    
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 37)
                
                VaultCardNew(index: UInt8(index), action: {}, useFullWidth: true)
                    .padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
                    //.shadow(radius: 10) //TODO: shadow
                
                Spacer()
                    .frame(height: 27)
                
                List {
                    ForEach(keyDisplayOptions, id: \.self) { mode in
                        SatoSelectionButton(mode: mode)
                            .onTapGesture {
                                
                                self.selectedMode = mode
                                // if the private key is not already available, scan the card to fetch it
                                if (cardState.vaultArray[index].privkey == nil) {
                                    
                                    if cardState.ownershipStatus == .owner {
                                        showPrivateKey()
                                    } else {
                                        // cardState.ownershipStatus == notOwner or unclaimed
                                        if cardState.isFixedCvc {
                                            if cardState.ownershipStatus == .unclaimed {
                                                showPrivateKey() // onwership will be taken automatically in unseal process
                                            }
                                            else if cardState.ownershipStatus == .notOwner {
                                                self.showUnlockDialog = true // ask user for CVC then proceed
                                            }
                                        } else {
                                            self.showNotOwnerAlert = true
                                            print("warning: failed to recover privkey: not owner!")
                                        }
                                    }
                                    
                                } else {
                                    self.isKeyViewPresented = true
                                }
                                
                            }.listRowBackground(Color.clear)
                    }
                    
                    ButtonBox(text: String(localized: "howDoiExportPrivateKey"), iconName: "ic_link") {
                        if let url = URL(string: "https://satochip.io/satodime-how-to-export-private-key/") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                .listRowSpacing(0)
                .background(Color.clear)
                
                NavigationLink(destination: ShowPrivateKeyView(index: index, mode: selectedMode), isActive: $isKeyViewPresented) {
                    EmptyView()
                }
            }
        } //ZStack
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
                else if showUnlockDialog {
                    UnlockCodeDialog(
                        isPresented: $showUnlockDialog,
                        title: "Enter CVC Code",
                        message: "Please enter the card CVC code to proceed",
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
                            self.showPrivateKey()
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
    }//body
}
