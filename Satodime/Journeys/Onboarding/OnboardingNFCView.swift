//
//  OnboardingNFCView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI

struct OnboardingNFCView: View {
    // MARK: - Properties
    let titleText = "usingNFC"
    let subtitleText = "toUseItText"
    
    // MARK: - Methods
    func goToMoreInfo() {
        if let url = URL(string: Constants.Links.moreInfo) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - View
    var body: some View {
        ZStack(alignment: .bottom) {
            
            VStack {
                Image("logo_satodime_white")
                    .resizable()
                    .scaledToFit()
                    .frame(height: Constants.Dimensions.satoDimeLogoHeight)
                Spacer()
                    .frame(height: Constants.Dimensions.verticalLogoSpacing)
                SatoText(text: titleText, style: .title)
                Spacer()
                    .frame(height: Constants.Dimensions.subtitleSpacing)
                SatoText(text: subtitleText, style: .subtitle)
                Spacer()
                    .frame(height: 34)
                SatoButton(text: String(localized: "moreInfo"), style: .inform, horizontalPadding: Constants.Dimensions.secondButtonPadding) {
                    goToMoreInfo()
                }
                Spacer()
            }
            .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.background {
            Image("view-background-onboard-3")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
    }
}
