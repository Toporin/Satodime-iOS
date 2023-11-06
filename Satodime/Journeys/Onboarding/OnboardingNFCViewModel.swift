//
//  OnboardingNFCViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI

final class OnboardingNFCViewModel: ObservableObject {
    // MARK: - Literals
    let titleText = "usingNFC"
    let subtitleText = "toUseItText"
    
    // MARK: - Methods
    func goToMoreInfo() {
        if let url = URL(string: Constants.Links.moreInfo) {
            UIApplication.shared.open(url)
        }
    }
}
