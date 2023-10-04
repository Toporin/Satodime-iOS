//
//  OnboardingInfoView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI

struct OnboardingInfoView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: OnboardingInfoViewModel
    
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
                SatoText(text: viewModel.titleText, style: .title)
                Spacer()
                    .frame(height: Constants.Dimensions.subtitleSpacing)
                SatoText(text: viewModel.subtitleText, style: .subtitle)
                Spacer()
                    .frame(height: 55)
                Image("il-onboard-2")
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.background {
            Image("view-background-onboard-2")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
    }
}
