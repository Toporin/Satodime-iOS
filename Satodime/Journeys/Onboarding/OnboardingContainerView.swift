//
//  OnboardingContainerView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI

enum OnboardingViewType {
    case welcome
    case info
    case nfc
}

struct OnboardingContainerView: View {
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    
    @State var currentPageIndex = 0 {
        didSet {
            self.isLastPageHandler()
        }
    }
    @State var isLastPage = false
    
    // MARK: - Literals
    let onboardingPages: [OnboardingViewType] = [.welcome, .info, .nfc]
    var numberOfPages: Int { onboardingPages.count }
    let startButtonTitle = String(localized: "start")

    func goToNextPage() {
        if currentPageIndex < numberOfPages - 1 {
            currentPageIndex = currentPageIndex + 1
        }
        self.isLastPageHandler()
    }
    
    private func isLastPageHandler() {
        if currentPageIndex == numberOfPages - 1 {
            isLastPage = true
        } else {
            isLastPage = false
        }
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: Constants.Storage.isAppPreviouslyLaunched)
        viewStackHandler.navigationState = .goBackHome
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                TabView(selection: $currentPageIndex) {
                    ForEach(Array(onboardingPages.enumerated()), id: \.offset) { index, page in
                        switch page {
                        case .welcome:
                            OnboardingWelcomeView()
                                .tag(index)
                        case .info:
                            OnboardingInfoView()
                                .tag(index)
                        case .nfc:
                            OnboardingNFCView()
                                .tag(index)
                        }
                    }
                }
                .onChange(of: currentPageIndex) { newValue in
                    currentPageIndex = newValue
                }
                .background {
                    Constants.Colors.viewBackground
                        .ignoresSafeArea()
                    if isLastPage {
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
            
            if isLastPage {
                SatoButton(text: startButtonTitle, style: .confirm, horizontalPadding: Constants.Dimensions.firstButtonPadding) {
                    self.completeOnboarding()
                }
                .padding(.bottom, Constants.Dimensions.defaultBottomMargin)
            } else {
                Button(action: {
                    goToNextPage()
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
    }
}
