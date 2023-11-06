//
//  ProductButton.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation
import SwiftUI

struct ProductButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Image("bg_btn_product")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 155)
                    .cornerRadius(20)
                    .clipped()

                VStack {
                    HStack {
                        Text(String(localized: "allOurProducts"))
                            .font(
                                Font.custom("Outfit", size: 20)
                                    .weight(.medium)
                            )
                            .foregroundColor(.white)
                            .padding([.top, .leading])
                        Spacer()
                    }
                    Spacer()
                }.frame(height: 155)
                
            }.frame(height: 155)
        }
    }
}
