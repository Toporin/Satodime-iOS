//
//  VaultsSnapList.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/11/2023.
//

import Foundation
import SwiftUI
import SnapToScroll

struct HStackSnapPlaceholder: View {
    private let height: CGFloat = 197

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: height)
    }
}

struct VaultsSnapList: View {
    
    var onSnapToScrollEvent: (SnapToScrollEvent) -> Void
    @ObservedObject var homeViewModel: HomeViewModel
    
    func buildEmptyCardView(id: Int) -> some View {
        VaultCardEmpty(id: id) {
            homeViewModel.emptyCardSealTapped(id: id)
        }
        .frame(width: 261, height: 197)
        .snapAlignmentHelper(id: id)
    }

    var body: some View {
        // if let vaultCards = self.homeViewModel.vaultCards {
        // VStack() {
            HStackSnap(alignment: .leading(20), spacing: 10) {
                ForEach(Array(self.homeViewModel.vaultCards.items.indices), id: \.self) { i in
                    let cardData = self.homeViewModel.vaultCards.items[i]
                    switch cardData {
                    case .vaultCard(let vaultCardViewModel):
                        VaultCard(viewModel: vaultCardViewModel, indexPosition: i)
                            .shadow(radius: 10)
                            .frame(width: 261, height: 197)
                            .snapAlignmentHelper(id: i)
                    case .emptyVault(_):
                        self.buildEmptyCardView(id: i)
                    }
                }
            } eventHandler: { event in
                // handleSnapToScrollEvent(event: event)
                onSnapToScrollEvent(event)
            }
            .frame(height: 197)
        // }
        /*} else {
            EmptyView()
                .frame(height: 197)
        }*/
    }
}
