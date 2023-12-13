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
    //@ObservedObject var viewModel: OnboardingNFCViewModel
    
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
            
            Image("view-background-onboard-3")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
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
                SatoButton(staticWidth: 111, text: String(localized: "moreInfo"), style: .inform) {
                    goToMoreInfo()
                }
                Spacer()
            }
            .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.background {
            
        }
    }
}
