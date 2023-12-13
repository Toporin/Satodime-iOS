//
//  OnboardingContainerViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI

//enum OnboardingViewType {
//    case welcome
//    case info
//    case nfc
//}

final class OnboardingContainerViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var currentPageIndex = 0
    let onboardingPages: [OnboardingViewType] = [.welcome, .info, .nfc]
    var numberOfPages: Int { onboardingPages.count }

    var isLastPage: Bool {
        return currentPageIndex == numberOfPages - 1
    }
    
    // MARK: - Literals
    let startButtonTitle = String(localized: "start")

    func goToNextPage() {
        if currentPageIndex < numberOfPages - 1 {
            currentPageIndex += 1
        }
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: Constants.Storage.isAppPreviouslyLaunched)
        navigateTo(destination: .goBackHome)
    
    }
}
