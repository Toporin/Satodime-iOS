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
    @Binding var isVerticalModeEnabled: Bool
    @Binding var currentSlotIndex: Int
    
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
                HStack {
                    SatoHeaderToggle(isOn: $isVerticalModeEnabled)
                        .padding(.trailing, 4)
                    
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
                            currentSlotIndex = 0
                        }
                    }) {
                        Image("ic_refresh")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }.padding(.trailing, 8)
                }
                .frame(maxWidth: 60)
            }
            
            // MENU
            Button(action: {
                DispatchQueue.main.async {
                    self.viewStackHandler.navigationState = .menu
                }
            }) {
                Image("ic_dots_vertical")
                    .resizable()
                    .frame(width: 24, height: 24)
            }.padding(.trailing, 22)
        }
        .frame(height: 48)
    }
}

struct SatoHeaderToggle: View {
    @Binding var isOn: Bool
    private let animationDuration: Double = 0.2
    let width: CGFloat = 40
    let height: CGFloat = 21
    let circleSize: CGFloat = 17.5

    var body: some View {
        Button(action: {
            withAnimation(.easeOut(duration: animationDuration)) {
                isOn.toggle()
            }
        }) {
            RoundedRectangle(cornerRadius: height/2)
                .fill(Constants.Colors.toggleBackground)
                .frame(width: width, height: height)
                .overlay(
                    HStack(spacing: 0) {
                        Image("ic_cards_horizontal")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .frame(width: width / 2, alignment: .center)
                        
                        Image("ic_cards_vertical")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .frame(width: width / 2, alignment: .center)
                    }
                )
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: circleSize, height: circleSize)
                        .shadow(radius: 2)
                        .offset(x: isOn ? (width / 2 - circleSize / 2 - 3) : -(width / 2 - circleSize / 2 - 3), y: 0)
                        .animation(.easeOut(duration: animationDuration), value: isOn)
                )
        }
        .frame(width: width, height: height)
    }
}
