//
//  TransferOwnershipView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation
import SwiftUI

struct TransferOwnershipView: View {
    // MARK: - Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    
    @Binding var showTakeOwnershipAlert: Bool // Binding to flags for showing TakeOwnershipView
    
    // MARK: - Literals
    let title = "transferOwner"
    let subtitle = "transferOwnershipDescription"
    let transferButtonTitle = String(localized: "transferBtn")
    let cancelButtonTitle = String(localized: "cancel")
    
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
                SatoText(text: subtitle, style: .graySubtitle).lineLimit(nil)
                Spacer()
                
                SatoButton(staticWidth: 196, text: transferButtonTitle, style: .confirm, horizontalPadding: 60) {
                    showTakeOwnershipAlert = false // reset flag to avoid user being asked to take ownership just after releasing it
                    cardState.releaseOwnership(
                        cardAuthentikeyHex: cardState.authentikeyHex,
                        onSuccess: {
                            DispatchQueue.main.async {
                                self.viewStackHandler.navigationState = .goBackHome
                            }
                        },
                        onFail: {
                            print("Error failed to release ownership!")
                            // TODO: show alert error
                        }
                    )
                }
                
                Spacer()
                    .frame(height: 37)
                
                SatoButton(staticWidth: 196, text: String(localized: "cancel"), style: .danger, horizontalPadding: 60) {
                    showTakeOwnershipAlert = false // disable so that user is not asked again?
                    DispatchQueue.main.async {
                        self.viewStackHandler.navigationState = .cardInfo //.goBackHome
                    }
                }
                
                Spacer()
                    .frame(height: 49)
            
            }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
        }// ZStack
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            showTakeOwnershipAlert = false // disable so that user is not asked again?
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
    }// body
}
