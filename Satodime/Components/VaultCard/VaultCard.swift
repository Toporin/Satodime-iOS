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
    // TODO: see https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-stateobject-property-wrapper
    // "You should use @StateObject only once per object, which should be in whichever view is responsible for creating the object. All other views that share your object should use @ObservedObject."
    
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
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            generator.impactOccurred()
                        }
                    }
                    if let weblink = viewModel.addressWebLink, let weblinkUrl = URL(string: weblink) {
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
                    BalanceView(title: viewModel.balanceTitle, balanceFirst: viewModel.fiatBalance, balanceSecond: viewModel.cryptoBalance)
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
