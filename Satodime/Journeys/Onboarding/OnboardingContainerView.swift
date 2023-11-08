//
//  OnboardingContainerView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var viewStackHandler: ViewStackHandler
    @ObservedObject var viewModel: OnboardingContainerViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                TabView(selection: $viewModel.currentPageIndex) {
                    ForEach(Array(viewModel.onboardingPages.enumerated()), id: \.offset) { index, page in
                        switch page {
                        case .welcome:
                            OnboardingWelcomeView(viewModel: OnboardingWelcomeViewModel())
                                .tag(index)
                        case .info:
                            OnboardingInfoView(viewModel: OnboardingInfoViewModel())
                                .tag(index)
                        case .nfc:
                            OnboardingNFCView(viewModel: OnboardingNFCViewModel())
                                .tag(index)
                        }
                    }
                }
                .onChange(of: viewModel.currentPageIndex) { newValue in
                    viewModel.currentPageIndex = newValue
                }
                .background {
                    Constants.Colors.viewBackground
                        .ignoresSafeArea()
                    if viewModel.isLastPage {
                        Image("view-background-onboard-3")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea()
                    } else {
                        Constants.Colors.viewBackground
                            .ignoresSafeArea()
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                .onAppear {
                    // TODO: Handling the onboarding completion
                }
            }
            
            if viewModel.isLastPage {
                SatoButton(staticWidth: 177, text: viewModel.startButtonTitle, style: .confirm, horizontalPadding: 60) {
                    self.viewModel.completeOnboarding()
                }
                .padding(.bottom, Constants.Dimensions.defaultBottomMargin)
            } else {
                Button(action: {
                    viewModel.goToNextPage()
                }) {
                    Image("bg_btn_arrow")
                        .resizable()
                        .frame(width: 71, height: 71)
                        .background(Color.clear)
                }
                .padding(.bottom, Constants.Dimensions.defaultBottomMargin)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.viewStackHandler = viewStackHandler
        }
    }
}
