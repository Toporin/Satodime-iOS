//
//  ActionButtonsView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 21/02/2024.
//

import Foundation
import SwiftUI

struct ActionButtonsView: View {
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @Binding var currentSlotIndex: Int
    
    var body: some View {
        HStack(spacing: 18) {
            if cardState.vaultArray.count > currentSlotIndex {
                if cardState.vaultArray[currentSlotIndex].getStatus() != .uninitialized {
                    AddFundsButton {
                        // self.navigateTo(destination: .addFunds)
                        DispatchQueue.main.async {
                            self.viewStackHandler.navigationState = .addFunds
                        }
                    }
                }
            
                if cardState.vaultArray[currentSlotIndex].getStatus() == .sealed {
                    UnsealButton {
                        // self.navigateTo(destination: .unseal)
                        DispatchQueue.main.async {
                            self.viewStackHandler.navigationState = .unseal
                        }
                    }
                }
                else if cardState.vaultArray[currentSlotIndex].getStatus() == .unsealed {
                    ShowKeyButton {
                        // self.navigateTo(destination: .privateKey)
                        DispatchQueue.main.async {
                            self.viewStackHandler.navigationState = .privateKey
                        }
                    }
                    ResetButton {
                        // self.navigateTo(destination: .reset)
                        DispatchQueue.main.async {
                            self.viewStackHandler.navigationState = .reset
                        }
                    }
                }
            }
        }
    }
}
