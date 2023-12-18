//
//  TakeOwnershipView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 07/10/2023.
//

import Foundation
import SwiftUI

struct TakeOwnershipView: View {
    // MARK: - Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    
    @Binding var showTakeOwnershipAlert: Bool
    
    // MARK: - Litterals
    let title = "takeTheOwnershipTitle"
    let subtitle = "takeTheOwnershipDescription"
    
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 37)
                Image("il-onboard-2")
                    .frame(maxHeight: 210)
                    .scaledToFit()
                Spacer()
                    .frame(height: 37)
                SatoText(text: subtitle, style: .subtitle)
                Spacer()
                SatoButton(staticWidth: 196, text: String(localized: "accept"), style: .confirm, horizontalPadding: 60) {
                    showTakeOwnershipAlert = false // disable so that user is not asked again
                    cardState.takeOwnership(
                        cardAuthentikeyHex: cardState.authentikeyHex,
                        onSuccess: {
                            DispatchQueue.main.async {
                                self.viewStackHandler.navigationState = .goBackHome
                            }
                        },
                        onFail: {
                            print("Error failed to take ownership!")
                            // TODO: show alert error
                        }
                    )
                }
                Spacer()
                    .frame(height: 20)
                SatoButton(staticWidth: 222, text: String(localized: "cancel"), style: .danger, horizontalPadding: 30) {
                    showTakeOwnershipAlert = false // disable so that user is not asked again
                    DispatchQueue.main.async {
                        self.viewStackHandler.navigationState = .cardInfo //.goBackHome
                    }
                }
                Spacer()
                    .frame(height: 49)
            
            }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            showTakeOwnershipAlert = false // disable so that user is not asked again
            DispatchQueue.main.async {
                self.viewStackHandler.navigationState = .cardInfo //.goBackHome
            }
        }) {
            Image("ic_flipback")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: title, style: .lightTitle)
            }
        }
    }
}
