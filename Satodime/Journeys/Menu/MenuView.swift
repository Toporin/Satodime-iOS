//
//  MenuView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//

import Foundation
import SwiftUI

enum SatochipURL: String {
    case howToUse = "https://satochip.io/setup-use-satodime-on-mobile/"
    case terms = "https://satochip.io/terms-of-service/"
    case privacy = "https://satochip.io/privacy-policy/"
    case products = "https://satochip.io/shop/"

    var url: URL? {
        return URL(string: self.rawValue)
    }
}

struct MenuView: View {
    // MARK: - Properties
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    
    @State var shouldShowCardInfo: Bool = false
    @State var shouldShowTransferOwnership: Bool = false
    @State var shouldShowSettings: Bool = false
    @State var showNotOwnerAlert: Bool = false
    @State var showCardNeedsToBeScannedAlert: Bool = false
    //@State var showTakeOwnershipAlert: Bool = false
    @State var shouldShowTakeOwnership: Bool = false
    @Binding var showTakeOwnershipAlert : Bool
    
    // MARK: - Litterals
    let notOwnerAlert = SatoAlert(
        title: "ownership",
        message: "ownershipText",
        buttonTitle: String(localized:"moreInfo"),
        buttonAction: {
            guard let url = URL(string: "https://satochip.io/satodime-ownership-explained/") else {
                print("Invalid URL")
                return
            }
            UIApplication.shared.open(url)
        }
    )
    
    let cardNeedToBeScannedAlert = SatoAlert(
        title: "cardNeedToBeScannedTitle",
        message: "cardNeedToBeScannedMessage",
        buttonTitle: "", //String(localized:"moreInfo"),
        buttonAction: {
//            guard let url = URL(string: "https://satochip.io") else {
//                print("Invalid URL")
//                return
//            }
//            UIApplication.shared.open(url)
        },
        isMoreInfoBtnVisible: false
    )
    
    // MARK: - Helpers
    func openURL(_ satochipURL: SatochipURL) {
        guard let url = satochipURL.url else {
            print("Invalid URL")
            return
        }
        UIApplication.shared.open(url)
    }
    
    // MARK: - View
    var body: some View {
        
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 29)
                
                Image("ic_logo_white_big")
                    .frame(width: 243, height: 87)
                
                Spacer()
                    .frame(height: 30)
                
                GeometryReader { geometry in
                    HStack(spacing: 10) {
                        
                        // CARD INFO
                        MenuButton(
                            title: String(localized: "cardInfo"),
                            iconName: "ic_credit_card",
                            iconWidth: 34, iconHeight: 34,
                            backgroundColor: Constants.Colors.grayMenuButton,
                            action: {
                                if cardState.hasReadCard() {
                                    self.shouldShowCardInfo = true
                                } else { //TODO: v0.1 & unclaimed ownership will trigger this
                                    showCardNeedsToBeScannedAlert = true
                                }
                            }
                        )
                        .frame(width: geometry.size.width * 0.50 - 15)
                        
                        // TRANSFER OWNERSHIP
                        MenuButton(
                            title: String(localized: "transferOwner"),
                            iconName: "ic_transfer_owner",
                            iconWidth: 27,
                            iconHeight: 27,
                            backgroundColor: Constants.Colors.blueMenuButton,
                            action: {
                                if cardState.ownershipStatus == .notOwner {
                                    self.showNotOwnerAlert = true
                                    print("warning: ownership transfer fail: not owner!")
                                } else if cardState.ownershipStatus == .owner {
                                    self.shouldShowTransferOwnership = true
                                    print("debug: show release ownership view!")
                                } else if cardState.ownershipStatus == .unclaimed {
                                    // TODO: take ownership?
                                    // self.showTakeOwnershipAlert = true
                                    self.shouldShowTakeOwnership = true
                                    print("debug: show take ownership view!")
                                } else {
                                    self.showCardNeedsToBeScannedAlert = true
                                    print("debug: show card needs to be scanned!")
                                }
                            }
                        )
                        .frame(width: geometry.size.width * 0.50 - 15)
                    }
                    .padding([.horizontal], 10)
                } // GeometryReader
                .frame(height: 120)
                
                Spacer()
                    .frame(height: 10)
                
                GeometryReader { geometry in
                    HStack(spacing: 10) {
                        
                        // HOW TO USE LINK
                        MenuButton(
                            title: String(localized: "howToUse"),
                            iconName: "ic_howto",
                            iconWidth: 34,
                            iconHeight: 34,
                            backgroundColor: Constants.Colors.greenMenuButton,
                            action: {
                                self.openURL(.howToUse)
                            }
                        )
                        .frame(width: geometry.size.width * 0.55 - 15)
                        
                        // SETTINGS
                        MenuButton(
                            title: String(localized: "settings"),
                            iconName: "ic_settings",
                            iconWidth: 27,
                            iconHeight: 27,
                            backgroundColor: Constants.Colors.blueMenuButton,
                            action: {
                                //viewModel.onSettings()
                                self.shouldShowSettings = true
                                //self.viewStackHandler.navigationState = .settings
                            }
                        )
                        .frame(width: geometry.size.width * 0.45 - 15)
                    }
                    .padding([.horizontal], 10)
                }// GeometryReader
                .frame(height: 120)
                
                Spacer()
                    .frame(height: 15)
                
                HStack(spacing: 10) {
                    SmallMenuButton(
                        text: String(localized: "termsOfService"),
                        backgroundColor: Constants.Colors.darkBlueMenuButton,
                        action: {
                            self.openURL(.terms)
                        }
                    )
                    
                    SmallMenuButton(
                        text: String(localized: "privacyPolicy"),
                        backgroundColor: Constants.Colors.darkBlueMenuButton,
                        action: {
                            self.openURL(.privacy)
                        }
                    )
                }
                .padding([.horizontal], 10)
                
                Spacer()
                
                Rectangle()
                    .frame(width: 108, height: 2)
                    .foregroundColor(Constants.Colors.separator)
                
                Spacer()
                
                ProductButton {
                    self.openURL(.products)
                }
                .frame(maxWidth: .infinity)
                .padding([.horizontal], 10)
                
                Spacer()
                    .frame(height: 29)
                
                NavigationLink(destination: CardInfoView(), isActive: $shouldShowCardInfo) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: TransferOwnershipView(showTakeOwnershipAlert: $showTakeOwnershipAlert), isActive: $shouldShowTransferOwnership) {
                    EmptyView()
                }
                
                NavigationLink(
                    //destination: TakeOwnershipView(showTakeOwnershipAlert: $showTakeOwnershipAlert), isActive: $showTakeOwnershipAlert)
                    destination: TakeOwnershipView(showTakeOwnershipAlert: $showTakeOwnershipAlert), isActive: $shouldShowTakeOwnership) {
                    EmptyView()
                }
                
                NavigationLink(destination: SettingsView(), isActive: $shouldShowSettings) {
                    EmptyView()
                }
            } // VStack
        } // ZStack
        // MARK: Overlays
        .overlay(
            Group {
                if showNotOwnerAlert {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showNotOwnerAlert = false
                            }
                        
                        SatoAlertView(isPresented: $showNotOwnerAlert, alert: notOwnerAlert)
                            .padding([.leading, .trailing], 24)
                    }
                }
//                else if showTakeOwnershipAlert {
//                    ZStack {
//                        Color.black.opacity(0.4)
//                            .ignoresSafeArea()
//                            .onTapGesture {
//                                showTakeOwnershipAlert = false
//                            }
//                        
//                        SatoAlertView(
//                            isPresented: $showTakeOwnershipAlert,
//                            alert: SatoAlert(
//                                title: "takeOwnership",
//                                message: "takeOwnershipText",
//                                buttonTitle: String(localized:"goToTakeOwnershipScreen"),
//                                buttonAction: {
//                                    self.viewStackHandler.navigationState = .takeOwnership
//                                }
//                            )
//                        )
//                            .padding([.leading, .trailing], 24)
//                    }
//                }
                else if showCardNeedsToBeScannedAlert {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showCardNeedsToBeScannedAlert = false
                            }
                        
                        SatoAlertView(isPresented: $showCardNeedsToBeScannedAlert, alert: cardNeedToBeScannedAlert)
                            .padding([.leading, .trailing], 24)
                    }
                }
            }
        ) // overlay
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.viewStackHandler.navigationState = .goBackHome
        }) {
            Image("ic_flipback")
        })

    }// body
}
