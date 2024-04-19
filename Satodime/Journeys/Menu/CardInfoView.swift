//
//  CardInfoView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation
import SwiftUI
import SatochipSwift

struct CardInfoView: View {
    // MARK: - Properties
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    
    @State var shouldShowAuthenticityScreen = false
    
    // MARK: - Literals
    let title = "cardInfo"
    //let authentikeyTitle = "authentikeyTitle" //TODO: translate
    
    let ownerTitle = "cardOwnershipStatus"
    let ownerText = "youAreTheCardOwner"
    let notOwnerText = "youAreNotTheCardOwner"
    let unclaimedOwnershipText = "cardHasNoOwner"
    let unknownOwnershipText = "Scan card to get ownership status"
    
    let cardVersionTitle = "cardVersion"
    
    let cardGenuineTitle = "cardAuthenticity"
    let cardGenuineText = "thisCardIsGenuine"
    let cardNotGenuineText = "thisCardIsNotGenuine"
    let certButtonTitle = "certDetails"
    
    // MARK: Helpers
    func getOwnershipStatus() -> String {
        switch cardState.ownershipStatus {
        case .owner:
            return ownerText
        case .notOwner:
            return notOwnerText
        case .unclaimed:
            return unclaimedOwnershipText
        case .unknown:
            return unknownOwnershipText // should not happen
        }
    }
    
    func getOwnershipColor() -> Color {
        switch cardState.ownershipStatus {
        case .owner:
            return Constants.Colors.darkLedGreen
        case .notOwner:
            return Constants.Colors.ledRed
        case .unclaimed:
            return Constants.Colors.ledBlue
        case .unknown:
            return Constants.Colors.lightGray
        }
    }
    
    func getCardVersionString(cardStatus: CardStatus?) -> String {
        if let cardStatus = cardStatus {
            let str = "Satodime v\(cardStatus.protocolMajorVersion).\(cardStatus.protocolMinorVersion)-\(cardStatus.appletMajorVersion).\(cardStatus.appletMinorVersion)"
            return str
        } else {
            return "n/a"
        }
    }
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 66)
                
                // OWNERSHIP
                SatoText(text: ownerTitle, style: .lightSubtitle)
                Spacer()
                    .frame(height: 14)
                CardInfoBox(text: getOwnershipStatus() , backgroundColor: getOwnershipColor())
                
                Spacer()
                    .frame(height: 33)
                
                // CARD VERSION
                SatoText(text: cardVersionTitle, style: .lightSubtitle)
                Spacer()
                    .frame(height: 14)
                CardInfoBox(text: self.getCardVersionString(cardStatus: cardState.cardStatus), backgroundColor: Constants.Colors.blueMenuButton)
                    .padding([.leading, .trailing], 82)
                
                Spacer()
                
//                // AUTHENTIKEY
//                SatoText(text: authentikeyTitle, style: .lightSubtitle)
//                Spacer()
//                    .frame(height: 14)
//                CardInfoBox(text: cardState.authentikeyHex , backgroundColor: Constants.Colors.blueMenuButton)
//                
//                Spacer()
                
                Rectangle()
                    .frame(width: .infinity, height: 2)
                    .foregroundColor(Constants.Colors.separator)
                    .padding([.leading, .trailing], 31)
                
                Spacer()
                
                // CERTIFICATE STATUS
                SatoText(text: cardGenuineTitle, style: .lightSubtitle)
                Spacer()
                    .frame(height: 14)
                CardInfoBox(
                    text: cardState.certificateCode == .success ? cardGenuineText : cardNotGenuineText,
                    backgroundColor: cardState.certificateCode == .success ? Constants.Colors.darkLedGreen : Constants.Colors.ledRed)
                {
                    self.shouldShowAuthenticityScreen = true
                }
                    .padding([.leading, .trailing], 57)
                
                Spacer()
                    .frame(height: 21)
                
                NavigationLink(destination: AuthenticView(shouldShowAuthenticityScreen: $shouldShowAuthenticityScreen, shouldBreakNavigationLink: true), isActive: $shouldShowAuthenticityScreen){
                    EmptyView()
                }
                
                Spacer()
                    .frame(height: 139)

            }.padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
            Button(action: {
                DispatchQueue.main.async {
                    viewStackHandler.navigationState = .menu
                }
            })
            {
                Image("ic_flipback")
            })
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: title, style: .lightTitle)
            }
        }
    } //body
}

