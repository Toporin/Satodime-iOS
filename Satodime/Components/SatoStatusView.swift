//
//  SatoStatusView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 06/10/2023.
//

import Foundation
import SwiftUI

enum CardReadState {
    case none
    case valid
    case invalid
}

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
    @ObservedObject var cardStatus: CardStatusObservable
    var onImageTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if cardStatus.status != .none {
                Image(cardStatus.cardStatusImage())
                    .resizable()
                    .frame(width: 6, height: 6)
            }
            
            Image("ic_sato_small")
                .resizable()
                .frame(width: 48, height: 48)
                .onTapGesture {
                    onImageTap()
                }
        }
        .frame(width: 54, height: 48)
    }
}
