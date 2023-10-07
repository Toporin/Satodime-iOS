//
//  VaultCard.swift
//  Satodime
//
//  Created by Lionel Delvaux on 05/10/2023.
//

import Foundation
import SwiftUI

struct VaultCard: View {
    let id: String
    let addressText: String
    let sealStatus: SealStatus
    let imageName: String
    let balanceTitle: String
    let balanceAmount: String
    let balanceCurrency: String

    var body: some View {
        ZStack {
            Image("bg_vault_card")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 261, height: 197)
                .clipped()
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color.black.opacity(0.7))
                .frame(width: 261, height: 197)
            
            VStack {
                HStack {
                    SatoText(text: "0\(id)", style: .slotTitle)
                    
                    Spacer()
                    
                    AddressView(text: addressText) {
                        
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                    .frame(height: 10)
                
                SealStatusView(status: sealStatus)
                
                Spacer()
                
                HStack {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    BalanceView(title: balanceTitle, balance: balanceAmount, cryptoBalance: balanceCurrency)
                }.padding(.bottom, 20)
            
            }.padding(20)
        }
    }
}

