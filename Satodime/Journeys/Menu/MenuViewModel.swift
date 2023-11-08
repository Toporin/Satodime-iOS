//
//  MenuViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//

import Foundation
import SwiftUI

enum SatochipURL: String {
    case howToUse = "https://satochip.io/setup-use-satodime-on-mobile/"
    case terms = "https://satochip.io/terms-of-service/"
    case privacy = "https://satochip.io/privacy-policy/"
    case products = "https://satochip.io/shop/"

    var url: URL? {
        return URL(string: self.rawValue)
    }
}

class MenuViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var cardVaults: CardVaults?
    @Published var shouldShowCardInfo: Bool = false
    @Published var shouldShowTransferOwnership: Bool = false
    @Published var shouldShowSettings: Bool = false
    @Published var showOwnershipAlert = false
    
    let ownershipAlert: SatoAlert = SatoAlert(title: "ownership", message: "ownershipText", buttonTitle: String(localized:"moreInfo"), buttonAction: {
            guard let url = URL(string: "https://satochip.io") else {
                print("Invalid URL")
                return
            }
        UIApplication.shared.open(url)
    })
    
    // MARK: - Literals
    
    // MARK: - Lifecycle
    init(cardVaults: CardVaults?) {
        self.cardVaults = cardVaults
    }
    
    func onCardInfo() {
        if cardVaults != nil {
            self.shouldShowCardInfo = true
        }
    }
    
    func onTransferOwner() {
        guard let isOwner = cardVaults?.isOwner, isOwner else {
            self.showOwnershipAlert = true
            return
        }
        
        self.shouldShowTransferOwnership = true
    }

    func onSettings() {
        self.shouldShowSettings = true
    }
        
    func openURL(_ satochipURL: SatochipURL) {
        guard let url = satochipURL.url else {
            print("Invalid URL")
            return
        }
        UIApplication.shared.open(url)
    }

}
