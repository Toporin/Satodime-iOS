//
//  HorizontalCardsView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 21/02/2024.
//

import Foundation
import SwiftUI

struct HorizontalCardsView: View {
    @EnvironmentObject var cardState: CardState
    @Binding var currentSlotIndex: Int
    
    var body: some View {
        CarouselCardsView(currentSlotIndex: $currentSlotIndex)
        
        Spacer()
            .frame(height: 16)
        
        ActionButtonsView(currentSlotIndex: $currentSlotIndex)
        
        Spacer()
            .frame(height: 16)
        
        // UI: Tokens & NFT tabs
        if cardState.vaultArray.count > currentSlotIndex
            && cardState.vaultArray[currentSlotIndex].getStatus() != .uninitialized
        {
            AssetTabView(index: currentSlotIndex, canSelectNFT: cardState.vaultArray[currentSlotIndex].coin.supportNft)
        } else {
            Spacer()
        }
    }
}
