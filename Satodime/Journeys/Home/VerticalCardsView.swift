//
//  VerticalCardsView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 21/02/2024.
//

import Foundation
import SwiftUI

struct VerticalCardsView: View {
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    @Binding var currentSlotIndex: Int
    @Binding var showNotOwnerAlert: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Spacer()
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(cardState.vaultArray, id: \.self) { vault in
                        VaultCardNew(
                            index: vault.index,
                            action: {
                                if cardState.ownershipStatus == .owner {
                                    DispatchQueue.main.async {
                                        self.viewStackHandler.navigationState = .vaultInitialization
                                    }
                                } else {
                                    self.showNotOwnerAlert = true
                                }
                            },
                            useFullWidth: true
                        )
                        .shadow(radius: 10)
                        .frame(height: 197)
                        .padding(.bottom, 16)
                    }
                }
                .padding(.horizontal, 20)
                .frame(width: geometry.size.width)
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}
