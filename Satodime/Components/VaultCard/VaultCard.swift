//
//  VaultCard.swift
//  Satodime
//
//  Created by Lionel Delvaux on 05/10/2023.
//

import Foundation
import SwiftUI

struct VaultCard: View {
    // MARK: - Properties
    @StateObject var viewModel: VaultCardViewModel
    let indexPosition: Int
    var useFullWidth: Bool = false

    var body: some View {
        ZStack {
            Image(viewModel.cardBackground)
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
                    SatoText(text: viewModel.positionText, style: .slotTitle)
                    Spacer()
                    AddressView(text: viewModel.addressText) {
                        UIPasteboard.general.string = viewModel.addressText
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                    .frame(height: 11)
                
                SealStatusView(status: viewModel.sealStatus)
                
                Spacer()
                
                HStack {
                    VStack {
                        VStack {
                            Spacer()
                            Image(viewModel.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .foregroundColor(.white)
                        }
                        if viewModel.isTestnet {
                            SatoText(text: "TESTNET", style: .addressText)
                        }
                    }
                    Spacer()
                    BalanceView(title: viewModel.balanceTitle, balance: viewModel.fiatBalance, cryptoBalance: viewModel.cryptoBalance)
                }
                .padding(.bottom, 20)
            }
            .padding(20)
        }
        .onAppear {
            viewModel.setIndexId(index: indexPosition)
        }
        .frame(maxWidth: useFullWidth ? .infinity : 261, minHeight: 197, maxHeight: 197)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
