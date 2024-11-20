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
                        DispatchQueue.main.async {
                            self.viewStackHandler.navigationState = .addFunds
                        }
                    }
                }
            
                if cardState.vaultArray[currentSlotIndex].getStatus() == .sealed {
                    UnsealButton {
                        DispatchQueue.main.async {
                            self.viewStackHandler.navigationState = .unseal
                        }
                    }
                }
                else if cardState.vaultArray[currentSlotIndex].getStatus() == .unsealed {
                    ShowKeyButton {
                        DispatchQueue.main.async {
                            self.viewStackHandler.navigationState = .privateKey
                        }
                    }
                    ResetButton {
                        DispatchQueue.main.async {
                            self.viewStackHandler.navigationState = .reset
                        }
                    }
                }
            }
        }
    }
}
