//
//  ExploreButton.swift
//  Satodime
//
//  Created by Satochip on 09/12/2023.
//

import Foundation
import SwiftUI

struct ExploreButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Image("bg_btn_addfunds") // todo change background?
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipped()
                    
                    Image("ic_link")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 43, height: 47)
                }
                .frame(width: 64, height: 64)
                
                Spacer()
                    .frame(height: 9)

                SatoText(text: "explore", style: .subtitle)
            }
        }
    }
}
