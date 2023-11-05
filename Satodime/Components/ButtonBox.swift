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
                    Text(text)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 25)
                        .padding(.trailing, 16)
                    
                    Image(systemName: iconName)
                        .resizable()
                        .frame(width: 31, height: 31)
                        .foregroundColor(.white)
                        .padding(.trailing, 25)
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
