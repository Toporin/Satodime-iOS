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
    @ObservedObject var viewModel: VaultSetupSelectChainViewModel
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 37)
                
                SatoText(text: viewModel.subtitle, style: .subtitle)
                
                Spacer()
                    .frame(height: 21)
                
                List(CryptoCurrency.allCases, id: \.id) { crypto in
                    ZStack {
                        NavigationLink(destination: VaultSetupCreateView(viewModel: VaultSetupCreateViewModel(selectedCrypto: crypto))) {
                            EmptyView()
                        }
                        CryptoSelectionCell(crypto: crypto)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    .listRowBackground(Constants.Colors.viewBackground)
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: viewModel.title, style: .viewTitle)
            }
        }
    }
}
