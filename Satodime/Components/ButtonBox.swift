//
//  ButtonBox.swift
//  Satodime
//
//  Created by Lionel Delvaux on 05/11/2023.
//

import Foundation
import SwiftUI

struct ButtonBox: View {
    var text: String
    var iconName: String
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            VStack {
                HStack {
                    SatoText(text: text, style: .cellTitle)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 20)
                        .padding(.trailing, 8)
                    
                    Spacer()
                    
                    Image(iconName)// Image(systemName: iconName)
                        .resizable()
                        .frame(width: 31, height: 31)
                        .foregroundColor(.white)
                        .padding(.trailing, 18)
                }
                .padding(.top, 18)
                .padding(.bottom, 18)
            }
            .frame(maxWidth: .infinity)
            .background(Constants.Colors.cellBackground)
            .cornerRadius(20)
        }
    }
}
