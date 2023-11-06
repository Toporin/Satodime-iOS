//
//  AuthenticViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//

import Foundation
import SwiftUI

enum AuthenticationState {
    case isAuthentic
    case notAuthentic
}

class AuthenticViewModel: BaseViewModel {
    
    @Published var imageForState: Image
    @Published var textForState: String
    @Published var backgroundColor: Color

    init(authState: AuthenticationState) {
        switch authState {
        case .isAuthentic:
            self.imageForState = Image("il_authentic")
            self.textForState = "authenticationSuccess"
            self.backgroundColor = Constants.Colors.viewBackground
        case .notAuthentic:
            self.imageForState = Image("il_not_authentic")
            self.textForState = "authenticationFailed"
            self.backgroundColor = Constants.Colors.errorViewBackground
        }
    }
}
