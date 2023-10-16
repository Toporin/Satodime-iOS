//
//  BaseViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 11/10/2023.
//

import Foundation
import SwiftUI

class BaseViewModel: ObservableObject {
    var viewStackHandler: ViewStackHandler?

    func navigateTo(destination: NavigationState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let _ = viewStackHandler else { return }
            self.viewStackHandler?.navigationState = destination
        }
    }
}
