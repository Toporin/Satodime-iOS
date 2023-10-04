//
//  OnboardingContainerViewModel.swift
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

final class OnboardingContainerViewModel: ObservableObject {
    @Published var currentPageIndex = 0

    let onboardingPages: [OnboardingViewType] = [.welcome, .info, .nfc]
    var numberOfPages: Int { onboardingPages.count }

    var isLastPage: Bool {
        return currentPageIndex == numberOfPages - 1
    }

    func goToNextPage() {
        if currentPageIndex < numberOfPages - 1 {
            currentPageIndex += 1
        }
    }
}
