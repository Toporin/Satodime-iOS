//
//  VaultSetupSelectChainView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 28/09/2023.
//

import Foundation
import SwiftUI

struct VaultSetupSelectChainView: View {
    // MARK: - Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    
    var index: Int
    
    // MARK: - Literals
    let title = "selectTheBlockchain"
    let subtitle = "selectTheCrypto"
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 37)
                
                SatoText(text: subtitle, style: .subtitle)
                
                Spacer()
                    .frame(height: 21)
                
                // Show the list of supported crypto
                List(CryptoCurrency.allCases, id: \.id) { crypto in
                    ZStack {
                        if crypto.isShowable {
                            NavigationLink(destination: VaultSetupCreateView(index: index, selectedCrypto: crypto)) {
                                EmptyView()
                            }
                            CryptoSelectionCell(crypto: crypto)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
                    .listRowBackground(Constants.Colors.viewBackground)
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
                
            }// VStack
        }// ZStack
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
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
    }// Body
}
