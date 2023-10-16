//
//  ResetButton.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import SwiftUI

struct ResetButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Image("bg_btn_reset")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipped()
                    
                    Image("ic_btn_reset")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                }
                .frame(width: 64, height: 64)
                
                Spacer()
                    .frame(height: 9)

                SatoText(text: "Reset", style: .subtitle)
            }
        }
    }
}
