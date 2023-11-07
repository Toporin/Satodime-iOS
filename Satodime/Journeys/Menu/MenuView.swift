//
//  MenuView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//

import Foundation
import SwiftUI

struct MenuView: View {
    // MARK: - Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandler
    @ObservedObject var viewModel: MenuViewModel
    
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
                        MenuButton(title: String(localized: "cardInfo"), iconName: "ic_credit_card", iconWidth: 34, iconHeight: 34, backgroundColor: Constants.Colors.grayMenuButton, action: {
                            self.viewModel.onCardInfo()
                        })
                        .frame(width: geometry.size.width * 0.50 - 15)

                        MenuButton(title: String(localized: "transferOwner"), iconName: "ic_transfer_owner", iconWidth: 27, iconHeight: 27, backgroundColor: Constants.Colors.blueMenuButton, action: {
                            self.viewModel.onTransferOwner()
                        })
                        .frame(width: geometry.size.width * 0.50 - 15)
                    }
                    .padding([.horizontal], 10)
                }.frame(height: 120)
                
                Spacer()
                    .frame(height: 10)
                
                GeometryReader { geometry in
                    HStack(spacing: 10) {
                        MenuButton(title: String(localized: "howToUse"), iconName: "ic_howto", iconWidth: 34, iconHeight: 34, backgroundColor: Constants.Colors.greenMenuButton, action: {
                            viewModel.openURL(.howToUse)
                        })
                        .frame(width: geometry.size.width * 0.65 - 15)
                        
                        MenuButton(title: String(localized: "settings"), iconName: "ic_settings", iconWidth: 27, iconHeight: 27, backgroundColor: Constants.Colors.blueMenuButton, action: {
                            viewModel.onSettings()
                        })
                        .frame(width: geometry.size.width * 0.35 - 15)
                    }
                    .padding([.horizontal], 10)
                }.frame(height: 120)
                
                Spacer()
                    .frame(height: 15)
                
                HStack(spacing: 10) {
                    SmallMenuButton(text: String(localized: "termsOfService"), backgroundColor: Constants.Colors.darkBlueMenuButton, action: {
                        viewModel.openURL(.terms)
                    })
                    
                    SmallMenuButton(text: String(localized: "privacyPolicy"), backgroundColor: Constants.Colors.darkBlueMenuButton, action: {
                        viewModel.openURL(.privacy)
                    })
                }
                .padding([.horizontal], 10)
                
                Spacer()
                
                Rectangle()
                    .frame(width: 108, height: 2)
                    .foregroundColor(Constants.Colors.separator)
                
                Spacer()
                
                ProductButton {
                    viewModel.openURL(.products)
                }
                .frame(maxWidth: .infinity)
                .padding([.horizontal], 10)
                
                Spacer()
                    .frame(height: 29)
                
                if let cardVaults = viewModel.cardVaults {
                    NavigationLink(
                        destination: CardInfoView(viewModel: CardInfoViewModel(cardVaults: cardVaults)),
                        isActive: $viewModel.shouldShowCardInfo
                    ) {
                        EmptyView()
                    }
                }

                NavigationLink(
                    destination: TransferOwnershipView(viewModel: TransferOwnershipViewModel(cardService: CardService())),
                    isActive: $viewModel.shouldShowTransferOwnership
                ) {
                    EmptyView()
                }
                NavigationLink(
                    destination: SettingsView(viewModel: SettingsViewModel(preferencesService: PreferencesService())),
                    isActive: $viewModel.shouldShowSettings
                ) {
                    EmptyView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.viewModel.navigateTo(destination: .goBackHome)
        }) {
            Image("ic_flipback")
        })
        .onAppear {
            viewModel.viewStackHandler = viewStackHandler
        }
    }
}
