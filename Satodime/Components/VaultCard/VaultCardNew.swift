//
//  VaultCardNew.swift
//  Satodime
//
//  Created by Satochip on 04/12/2023.
//

import Foundation
import SwiftUI

struct VaultCardNew: View {
    // MARK: Properties
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    
    @State var showNotOwnerAlert: Bool = false
    
    // MARK: Litterals
    let index: UInt8
    let action: () -> Void
    var useFullWidth: Bool = false
    
    // MARK: Body
    var body: some View {
        if index >= cardState.vaultArray.count {
            //VaultCardEmpty(id: Int(index), action: {}) //TODO?
        } else if cardState.vaultArray[Int(index)].keyslotStatus.status == 0x00 {
            VaultCardEmpty(
                id: Int(index),
                action: {action()}
            )
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
                        // VAULT NUMBER
                        SatoText(text:  "0\(index+1)", style: .slotTitle)
                        Spacer()
                        
                        // ADDRESS
                        AddressView(text: cardState.vaultArray[Int(index)].address) {
                            UIPasteboard.general.string = cardState.vaultArray[Int(index)].address
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.prepare()
                            generator.impactOccurred()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                generator.impactOccurred()
                            }
                        }
                        // EXPLORER Button
                        if let weblinkUrl = cardState.vaultArray[Int(index)].addressUrl {
                            Button(action: {
                                UIApplication.shared.open(weblinkUrl)
                            }) {
                                Image("ic_link")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                        .frame(height: 11)
                    
                    // VAULT STATUS (sealed/Unsealed/uninitialized
                    SealStatusView(status: cardState.vaultArray[Int(index)].getStatus())
                    
                    Spacer()
                    
                    HStack {
                        //ICON
                        VStack {
                            VStack {
                                Spacer()
                                Image(cardState.vaultArray[Int(index)].coinMeta.icon)
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
                        
                        // BALANCE
                        BalanceView(
                            title: cardState.vaultArray[Int(index)].coin.displayName, //String(localized: "totalBalance"),
                            balanceFirst: SatodimeUtil.formatBalance(balanceDouble: cardState.vaultArray[Int(index)].balance, symbol: cardState.vaultArray[Int(index)].coin.coinSymbol),
                            balanceSecond: SatodimeUtil.formatBalance(balanceDouble: cardState.vaultArray[Int(index)].coinValueInSecondCurrency,  symbol: cardState.vaultArray[Int(index)].selectedSecondCurrency, maxFractionDigit: 2)
                        )
                    }
                    .padding(.bottom, 20)
                }
                .padding(20)
            } // ZStack
            .frame(maxWidth: useFullWidth ? .infinity : 261, minHeight: 197, maxHeight: 197)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        } // if
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
