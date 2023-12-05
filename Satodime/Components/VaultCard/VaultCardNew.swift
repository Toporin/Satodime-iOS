//
//  VaultCardNew.swift
//  Satodime
//
//  Created by Satochip on 04/12/2023.
//

import Foundation
import SwiftUI

struct VaultCardNew: View {
    
    @EnvironmentObject var cardState: CardState
    
    let index: UInt8
    var useFullWidth: Bool = false

    var body: some View {
        if index >= cardState.vaultArray.count {
            VaultCardEmpty(id: Int(index), action: {}) //TODO?
        } else if cardState.vaultArray[Int(index)].keyslotStatus.status == 0x00 {
            VaultCardEmpty(id: Int(index), action: {}) //TODO: action
        } else {
            ZStack {
                Image(backgroundImageName())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: useFullWidth ? .infinity : 261, minHeight: 197, maxHeight: 197)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.1))
                    )
                
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color.black.opacity(0.1))
                    .frame(maxWidth: useFullWidth ? .infinity : 261, minHeight: 197, maxHeight: 197)
                
                VStack {
                    HStack {
                        SatoText(text:  "0\(index+1)", style: .slotTitle)
                        Spacer()
                        AddressView(text: cardState.vaultArray[Int(index)].address) {
                            UIPasteboard.general.string = cardState.vaultArray[Int(index)].address
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.prepare()
                            generator.impactOccurred()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                generator.impactOccurred()
                            }
                        }
                        // TODO: add button in action
//                        if let weblink = viewModel.addressWebLink, let weblinkUrl = URL(string: weblink) {
//                            Button(action: {
//                                UIApplication.shared.open(weblinkUrl)
//                            }) {
//                                Image("ic_link")
//                                    .resizable()
//                                    .frame(width: 32, height: 32)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                        .frame(height: 11)
                    
                    SealStatusView(status: cardState.vaultArray[Int(index)].getStatus())
                    
                    Spacer()
                    
                    HStack {
                        VStack {
                            VStack {
                                Spacer()
                                Image(cardState.vaultArray[Int(index)].iconPath)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 26, height: 26)
                                    .foregroundColor(.white)
                            }
                            if cardState.vaultArray[Int(index)].coin.isTestnet {
                                SatoText(text: "TESTNET", style: .addressText)
                            }
                        }
                        Spacer()
                        BalanceView(title: String(localized: "totalBalance"), balance: cardState.vaultArray[Int(index)].getCoinValueInSecondCurrencyString(), cryptoBalance: cardState.vaultArray[Int(index)].getCoinBalanceString())
                        
                    }
                    .padding(.bottom, 20)
                }
                .padding(20)
            }
            .frame(maxWidth: useFullWidth ? .infinity : 261, minHeight: 197, maxHeight: 197)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        
//        ZStack {
//            Image(viewModel.cardBackground)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(maxWidth: useFullWidth ? .infinity : 261, minHeight: 197, maxHeight: 197)
//                .clipShape(RoundedRectangle(cornerRadius: 20))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color.black.opacity(0.1))
//                )
//            
//            RoundedRectangle(cornerRadius: 20)
//                .foregroundColor(Color.black.opacity(0.1))
//                .frame(maxWidth: useFullWidth ? .infinity : 261, minHeight: 197, maxHeight: 197)
//            
//            VStack {
//                HStack {
//                    SatoText(text: viewModel.positionText, style: .slotTitle)
//                    Spacer()
//                    AddressView(text: viewModel.addressText) {
//                        UIPasteboard.general.string = viewModel.addressText
//                        let generator = UIImpactFeedbackGenerator(style: .medium)
//                        generator.prepare()
//                        generator.impactOccurred()
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                            generator.impactOccurred()
//                        }
//                    }
//                    if let weblink = viewModel.addressWebLink, let weblinkUrl = URL(string: weblink) {
//                        Button(action: {
//                            UIApplication.shared.open(weblinkUrl)
//                        }) {
//                            Image("ic_link")
//                                .resizable()
//                                .frame(width: 32, height: 32)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .padding(.top, 20)
//                
//                Spacer()
//                    .frame(height: 11)
//                
//                SealStatusView(status: viewModel.sealStatus)
//                
//                Spacer()
//                
//                HStack {
//                    VStack {
//                        VStack {
//                            Spacer()
//                            Image(viewModel.imageName)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 26, height: 26)
//                                .foregroundColor(.white)
//                        }
//                        if viewModel.isTestnet {
//                            SatoText(text: "TESTNET", style: .addressText)
//                        }
//                    }
//                    Spacer()
//                    BalanceView(title: viewModel.balanceTitle, balance: viewModel.fiatBalance, cryptoBalance: viewModel.cryptoBalance)
//                }
//                .padding(.bottom, 20)
//            }
//            .padding(20)
//        }
//        .onAppear {
//            viewModel.setIndexId(index: indexPosition)
//        }
//        .frame(maxWidth: useFullWidth ? .infinity : 261, minHeight: 197, maxHeight: 197)
//        .clipShape(RoundedRectangle(cornerRadius: 20))
    } // body
    
    func backgroundImageName() -> String {
        if cardState.vaultArray[Int(index)].keyslotStatus.status == 0x02 { // unsealed
            return "bg_card_unsealed"
        }
        else if index%3 == 0 {
            return "bg_vault_card"
        }
        else if index%3 == 1 {
            return "bg_vault_card_2"
        }
        else {
            return "bg_vault_card_3"
        }
    }
    
}// view
