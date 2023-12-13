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
    
    // MARK: - Properties
    //let logger = ConsoleLogger()
    //let cardService: PCardService
    
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
                    //viewModel.transferCard()
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
                
                SatoButton(staticWidth: 196, text: "cancelButtonTitle", style: .confirm, horizontalPadding: 60) {
                    self.viewStackHandler.navigationState = .goBackHome
                }
                
                Spacer()
                    .frame(height: 49)
            
            }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.viewStackHandler.navigationState = .goBackHome
        }) {
            Image("ic_flipback")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: title, style: .lightTitle)
            }
        }
//        .onAppear {
//            viewModel.viewStackHandler = viewStackHandler
//        }
    }// body
}
