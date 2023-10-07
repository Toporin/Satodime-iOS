//
//  OnboardingModel.swift
//  Onboarding
//
//  Created by Augustinas Malinauskas on 06/07/2020.
//  Copyright © 2020 Augustinas Malinauskas. All rights reserved.
//

import Foundation
import SwiftUI

struct OnboardingDataModel {
    var image: String
    var heading: String
    var text: String
}

extension OnboardingDataModel {
    static var data: [OnboardingDataModel] = [
        OnboardingDataModel(image: "onboarding-intro1", heading: String(localized: "Welcome!"), text: String(localized: "text_intro1")),
        OnboardingDataModel(image: "onboarding-intro2", heading: String(localized: "Use it indefinitely"), text: String(localized: "text_intro2")),
        OnboardingDataModel(image: "onboarding-nfc", heading: String(localized: "How to use NFC"), text: String(localized: "text_intro3")),
        OnboardingDataModel(image: "onboarding-example", heading: String(localized: "A sample vault"), text: String(localized: "text_intro4")),
    ]
}
