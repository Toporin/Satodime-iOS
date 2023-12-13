//
//  OnBoardingWelcomeView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI

struct OnboardingWelcomeView: View {
    // MARK: - Properties
    //@ObservedObject var viewModel: OnboardingWelcomeViewModel
    // MARK: - Literals
    let titleText = "welcome"
    let subtitleText = "satodimeLetsYou"
    
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
                    .frame(height: Constants.Dimensions.verticalIllustrationSpacing)
                Image("il-onboard-1")
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.background {
            Image("view-background-onboard-1")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
    }
}
