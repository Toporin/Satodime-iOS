//
//  VaultSetupCreateView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 02/10/2023.
//

import Foundation
import SwiftUI
import CryptoSwift

struct VaultSetupCreateView: View {
    // MARK: - Properties
    //@ObservedObject var viewModel: VaultSetupCreateViewModel
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    
    // MARK: - Properties
    var index: Int
    var selectedCrypto: CryptoCurrency
    
    //let cardService: PCardService
    
    @State var isExpertModeActivated = false
    @State var isNextViewActive = false // TODO: rename
    //@State var isExpertModeViewActive = false
    //@State var vaultCards: VaultsList
    
    // expert mode
    @State var selectedNetwork: NetworkMode = .mainNet
    @State var entropy: String = ""
    
    // MARK: - Literals
    let title = "createYourVault"
    let subtitle = "youAreAboutToCreateAndSeal"
    let informationText = "onceTheVaultHasBeengenerated"
    let activateExpertModeText = String(localized: "activateTheExpertMode")
    let continueButtonTitle = String(localized: "createAndSeal")
    
    // expert mode
    let expertTitle = "expertMode"
    let expertInformationText = "theExpertModeAllowsYou"
    let networkChoiceSystem = "network"
    let mainNetText = "mainNet"
    let testNetText = "testNet"
    let entropyTitle = "entropy"
    let entropyPlaceholder = String(localized: "enterAnyTextHereToAddEntropy")
    
    // MARK: - Helpers
    
    private func isTestnet() -> Bool {
        return self.selectedNetwork == .testNet
    }
    
    // convert user provided string to 32-bytes of entropy
    private func extractEntropy(randomString: String) -> [UInt8] {
        var randomBytes = Array(randomString.utf8)
        if (randomBytes.count>32){
            randomBytes = Digest.sha256(randomBytes)
        } else if randomBytes.count<32 {
            randomBytes = randomBytes + [UInt8](repeating: 0, count: 32-randomBytes.count)
        }
        return randomBytes
    }
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 37)
                    
                    SatoText(text: subtitle, style: .graySubtitle)
                    
                    Spacer()
                        .frame(height: 37)
                    
                    SatoText(text: selectedCrypto.shortIdentifier, style: .subtitleBold)
                    
                    Spacer()
                        .frame(height: 16)
                    
                    ZStack {
                        Circle()
                            .fill(selectedCrypto.color)
                            .frame(width: 100, height: 100)
                            .padding(10)
                        
                        Image(selectedCrypto.icon)
                            .frame(width: 100, height: 100)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                        .frame(height: 65)
                    
                    SatoText(text: informationText, style: .graySubtitle)
                        .frame(maxWidth: .infinity, minHeight: 91)
                        .background(Constants.Colors.cellBackground)
                        .cornerRadius(20)
                    
                    Spacer()
                        .frame(height: 22)
                    
                    SettingsToggle(
                        title: "switchToExpertMode",
                        backgroundColor: Constants.Colors.blueMenuButton,
                        isOn: $isExpertModeActivated,
                        onToggle: { newValue in
                            // do nothing
                        }
                    )
                    
                    Spacer()
                    
                    // expert mode
                    if isExpertModeActivated {
                        
                        Spacer()
                            .frame(height: 37)
                        
                        HStack {
                            SatoText(text: networkChoiceSystem, style: .subtitle, alignment: .leading)
                            Spacer()
                        }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                        
                        Spacer()
                            .frame(height: 15)
                        
                        Rectangle()
                            .frame(width: .infinity, height: 2)
                            .foregroundColor(Constants.Colors.separator)
                            .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                        
                        SatoChoiceSelector(selectedItem: $selectedNetwork, items: NetworkMode.allCases)
                            .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                        
                        Rectangle()
                            .frame(width: .infinity, height: 2)
                            .foregroundColor(Constants.Colors.separator)
                            .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                        
                        Spacer()
                            .frame(height: 28)
                        
                        HStack {
                            SatoText(text: entropyTitle, style: .subtitle, alignment: .leading)
                            Spacer()
                        }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                        
                        Spacer()
                            .frame(height: 15)
                        
                        SatoInputText(text: $entropy, placeholder: entropyPlaceholder)
                        // TODO: placeholder in entropy field
                        
                    } // end isExpertModeActivated
                    
                    SatoButton(staticWidth: 177, text: continueButtonTitle, style: .confirm) {
                        //viewModel.sealSlot()
                        let entropyBytes: [UInt8]
                        if isExpertModeActivated {
                            entropyBytes = self.extractEntropy(randomString: entropy)
                        } else {
                            let date = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "y, MMM d, HH:mm:ss"
                            let dateString = dateFormatter.string(from: date)
                            entropyBytes = self.extractEntropy(randomString: dateString) //use current date as default entropy
                            // TODO: use btc latest coinbase info ?
                        }
                        
                        //                    let actionParams = ActionParameters(index: UInt8(index), action: .sealVault, coinType: selectedCrypto.coinType, useTestnet: isTestnet(), entropyBytes: entropyBytes)
                        //                    cardState.scanForAction(actionParams: actionParams)
                        //
                        //                    DispatchQueue.main.async {
                        //                        // TODO: check result?
                        //                        // TODO: if error?
                        //                        self.isNextViewActive = true
                        //                        print("Sealed!")
                        //                    }
                        //
//                        let actionParams = ActionParameters(index: UInt8(index), action: .sealVault, coinType: selectedCrypto.coinType, useTestnet: isTestnet(), entropyBytes: entropyBytes) // TODO: remove and just compute slip44
                        cardState.sealVault(
                            cardAuthentikeyHex: cardState.authentikeyHex,
                            index: index,
                            slip44: isTestnet() ? (selectedCrypto.slip44 & 0x7fffffff) : selectedCrypto.slip44, // set first byte to 0 for testnet
                            entropyBytes: entropyBytes,
                            onSuccess: {
                                print("Debug seal vault  \(index) successfully!")
                                print("Debug seal vault selectedCrypto: \(selectedCrypto)!")
                                print("Debug seal vault selectedCrypto.icon: \(selectedCrypto.icon)!")
                                DispatchQueue.main.async {
                                    self.isNextViewActive = true
                                    self.viewStackHandler.navigationState = .vaultSetupCongrats
                                }
                            },
                            onFail: {
                                print("Error failed to seal vault \(index)!")
                                // TODO: show alert error
                            }
                        )
                        //self.presentationMode.wrappedValue.dismiss()
                    }
                    
                    // TODO: cancel button?
                    
                    //                NavigationLink(
                    //                    destination: VaultSetupCongratsView(selectedCrypto: selectedCrypto),
                    //                    //destination: VaultSetupCongratsView(),
                    //                    isActive: $isNextViewActive
                    //                ) {
                    //                    EmptyView()
                    //                }
                    //                .navigationViewStyle(.stack)
                    
                    // error: NavigationLink presenting a value must appear inside a NavigationContent-based NavigationView. Link will be disabled.
                    // No image named 'ic_coin_empty' found in asset catalog for
                    //                if (isNextViewActive){
                    //                    NavigationLink("", destination: VaultSetupCongratsView(selectedCrypto: self.selectedCrypto), isActive: .constant(true))
                    //                        .hidden()
                    //                        .navigationViewStyle(.stack)
                    //                }
                    
                    
                    Spacer()
                        .frame(height: 29)
                    
                }// VStack
                .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
            }// Scrollview
        }// ZStack
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: title, style: .lightTitle)
            }
        }
    }
}
