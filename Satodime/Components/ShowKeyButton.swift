//
//  ShowKeyButton.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import SwiftUI

struct ShowKeyButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Image("bg_btn_showkey")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipped()
                    
                    Image("ic_btn_showkey")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 43, height: 47)
                }
                .frame(width: 64, height: 64)
                
                Spacer()
                    .frame(height: 9)

                SatoText(text: "Show key", style: .subtitle)
            }
        }
    }
}
