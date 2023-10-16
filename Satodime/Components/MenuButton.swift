//
//  MenuButton.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation
import SwiftUI

struct MenuButton: View {
    let title: String
    let iconName: String
    let iconWidth: CGFloat
    let iconHeight: CGFloat
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding([.top, .leading])
                    Spacer()
                }
                HStack {
                    Spacer()
                    Image(iconName)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: iconWidth, height: iconHeight)
                        .padding([.trailing, .bottom])
                }
            }
            .frame(maxWidth: .infinity, minHeight: 107, maxHeight: 107)
            .background(backgroundColor)
            .cornerRadius(20)
        }
    }
}
