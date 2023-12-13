//
//  AuthenticViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//

import Foundation
import SwiftUI

//enum AuthenticationState {
//    case isAuthentic
//    case notAuthentic
//}

final class AuthenticViewModel: BaseViewModel {
    
    @Published var imageForState: Image
    @Published var textForState: String
    @Published var backgroundColor: Color
    
    var destinationOnClose: NavigationState?

    init(authState: AuthenticationState, viewStackHandler: ViewStackHandler? = nil, destinationOnClose: NavigationState? = nil) {
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
        super.init()
        self.viewStackHandler = viewStackHandler
        self.destinationOnClose = destinationOnClose
        /*if let viewStackHandler = viewStackHandler, self.viewStackHandler == nil {
            self.viewStackHandler = viewStackHandler
        }*/
    }
}
