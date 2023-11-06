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
        HStack {
            VStack {
                Spacer()
                    .frame(height: 5)
                
                if cardStatus.status != .none {
                    Image(cardStatus.cardStatusImage())
                        .resizable()
                        .frame(width: 6, height: 6)
                }
                
                Spacer()
            }

            Spacer()
                .frame(width: 0)
            
            ZStack {
                Image("ic_sato_small")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .onTapGesture {
                        onImageTap()
                    }
                
                if cardStatus.status == .invalid {
                    VStack {
                        HStack {
                            Spacer()
                                .frame(width: 4)
                            
                            Text(String(localized: "error"))
                                .font(.system(size: 9))
                                .foregroundColor(Constants.Colors.ledRed)
                                .padding(.vertical, 3)
                                .padding(.horizontal, 6)
                                .background(
                                    Color.black.opacity(0.3)
                                        .cornerRadius(3)
                                )
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            .frame(width: 54, height: 48)
        }
    }
}
