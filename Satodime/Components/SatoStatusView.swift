//
//  SatoStatusView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 06/10/2023.
//

import Foundation
import SwiftUI
import SatochipSwift

// todo remove
enum CardReadState {
    case none
    case valid
    case invalid
}

// TODO: remove? //merge with isCardAuthentic  & CardAuthenticity ??
class CardStatusObservable: ObservableObject {
    @Published var status: CardReadState = .none
    func cardStatusImage() -> String {
        switch status {
        case .none:
            return ""
        case .valid:
            return "ic_circle_valid"
        case .invalid:
            return "ic_circle_invalid"
        }
    }
}

struct SatoStatusView: View {
    
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    
    var body: some View {
        
        if cardState.certificateCode == .success {
            Image("ic_sato_small")
                .resizable()
                .frame(width: 48, height: 48)
                .onTapGesture {
                    DispatchQueue.main.async {
                        self.viewStackHandler.navigationState = .cardAuthenticity
                    }
                }
        } else if cardState.certificateCode == .unknown { // TODO: somethin special?
            Image("ic_sato_small") // TODO: orange icon?
                .resizable()
                .frame(width: 48, height: 48)
                .onTapGesture {
                    DispatchQueue.main.async {
                        self.viewStackHandler.navigationState = .cardAuthenticity
                    }
                }
        } else {
            Image("il_not_authentic") // TODO: red icon
                .resizable()
                .frame(width: 48, height: 48)
                .onTapGesture {
                    DispatchQueue.main.async {
                        self.viewStackHandler.navigationState = .cardAuthenticity
                    }
                }
        }
    } // body
}
