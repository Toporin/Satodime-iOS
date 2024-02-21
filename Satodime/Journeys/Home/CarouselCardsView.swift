//
//  CarouselCardsView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 21/02/2024.
//

import Foundation
import SwiftUI
import SnapToScroll

struct CarouselCardsView: View {
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @Binding var currentSlotIndex: Int
    
    var body: some View {
        VStack {
            // UI: horizontal cards stack display
            // Quick hack as HStackSnap does not support dynamic data
            if cardState.vaultArray.isEmpty {
                HStackSnap(alignment: .leading(20), spacing: 10) {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.clear, lineWidth: 2)
                        .frame(width: 261, height: 197)
                        .snapAlignmentHelper(id: 0)
                } eventHandler: { event in
                    handleSnapToScrollEvent(event: event)
                }
                .frame(height: 197)
            } else {
                HStackSnap(alignment: .leading(20), spacing: 10) {
                    ForEach(cardState.vaultArray, id: \.self){ vault in
                        VaultCardNew(
                            index: vault.index,
                            action: {
                                if cardState.ownershipStatus == .owner {
                                    print("DEBUG click on seal new vault!")
                                    DispatchQueue.main.async {
                                        self.viewStackHandler.navigationState = .vaultInitialization
                                    }
                                    print("DEBUG click on seal new vault AFTER!")
                                } else {
                                    // not owner alert message
                                    // \/ TODO: Is this needed ? \/
                                    //self.showNotOwnerAlert = true
                                }
                            }
                        )
                            .shadow(radius: 10)
                            .frame(width: 261, height: 197)
                            .snapAlignmentHelper(id: vault.index)
                    }
                } eventHandler: { event in
                    handleSnapToScrollEvent(event: event)
                }
                .frame(height: 197)
            } // end HStackSnap
        }
    }
    
    func handleSnapToScrollEvent(event: SnapToScrollEvent) {
        switch event {
            case let .didLayout(layoutInfo: layoutInfo):
            print("\(layoutInfo.keys.count) items layed out")
            case let .swipe(index: index):
            currentSlotIndex = index
            print("swiped to index: \(index)")
        }
    }
}
