//
//  HeaderView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 21/02/2024.
//

import Foundation
import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    
    @Binding var showNotOwnerAlert: Bool
    @Binding var showNotAuthenticAlert: Bool
    @Binding var showCardNeedsToBeScannedAlert: Bool
    // show the TakeOwnershipView if card is unclaimed, this is transmitted with CardInfoView
    @Binding var showTakeOwnershipAlert: Bool
    
    // MARK: - Literals
    let viewTitle: String = "vaults"
    
    var body: some View {
        // UI: Logo + vault title + refresh button + 3-dots menu
        HStack {
            
            // Logo with authenticity status
            SatoStatusView()
                .padding(.leading, 22)
                .onTapGesture(count: 1){
                    if !self.cardState.hasReadCard() {
                        showCardNeedsToBeScannedAlert = true
                    } else {
                        DispatchQueue.main.async {
                            self.viewStackHandler.navigationState = .cardAuthenticity
                        }
                    }
                }
            
            Spacer()
            
            // Title
            SatoText(text: viewTitle, style: .title)
            
            Spacer()
            
            // trigger scan card & web API
            if !cardState.vaultArray.isEmpty {
                Button(action: {
                    Task {
                        await cardState.executeQuery()
                    }
                    // reset flag when scanning a new card
                    // TODO: Delay execution should not be used as a solution
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showTakeOwnershipAlert = true
                        showNotOwnerAlert = true
                        showNotAuthenticAlert = true
                    }
                }) {
                    Image("ic_refresh")
                        .resizable()
                        .frame(width: 24, height: 24)
                }.padding(.trailing, 8)
            }
            
            // MENU
            Button(action: {
                // self.navigateTo(destination: .menu)
                DispatchQueue.main.async {
                    self.viewStackHandler.navigationState = .menu
                }
            }) {
                Image("ic_dots_vertical")
                    .resizable()
                    .frame(width: 24, height: 24)
            }.padding(.trailing, 22)
        } // end hstack
        .frame(height: 48)
    }
}
