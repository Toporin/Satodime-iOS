//
//  SmallMenuButton.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation
import SwiftUI

struct SmallMenuButton: View {
    let text: String
    let backgroundColor: Color
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.leading)

                Spacer()
                    .frame(width: 12)

                Image(iconName)
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.white)
                    .padding(.trailing)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 57)
            .background(backgroundColor)
            .cornerRadius(20)
        }
    }
}
