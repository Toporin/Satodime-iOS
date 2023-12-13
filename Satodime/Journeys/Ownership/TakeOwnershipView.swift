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
    //@EnvironmentObject var viewStackHandler: ViewStackHandler
    //@ObservedObject var viewModel: TakeOwnershipViewModel
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    
    let logger = ConsoleLogger()
    //let cardService: PCardService
    //var cardVaults: CardVaults
    var destinationOnClose: NavigationState?
    
    // MARK: - Literals
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
                    //viewModel.acceptCard()
//                    let actionParams = ActionParameters(index: 0xFF, action: .takeOwnership)
//                    cardState.scanForAction(actionParams: actionParams)
//                    // TODO: return to home??
                    
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
                SatoButton(staticWidth: 222, text: String(localized: "cancel"), style: .inform, horizontalPadding: 30) {
                    //viewModel.cancel()
                    self.viewStackHandler.navigationState = .goBackHome
                }
                Spacer()
                    .frame(height: 49)
            
            }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
//            if let destinationOnClose = viewModel.destinationOnClose {
//                self.viewModel.navigateTo(destination: destinationOnClose)
//            } else {
//                self.viewModel.navigateTo(destination: .goBackHome)
//            }
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
    }
}
