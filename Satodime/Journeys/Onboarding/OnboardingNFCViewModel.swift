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
    let titleText = "Using NFC"
    let subtitleText = "To use it, put the card on top of your phone when prompted and keep it on the reader throughout the operation."
    
    // MARK: - Methods
    func goToMoreInfo() {
        if let url = URL(string: Constants.Links.moreInfo) {
            UIApplication.shared.open(url)
        }
    }
}
