//
//  AddFundsButton.swift
//  Satodime
//
//  Created by Lionel Delvaux on 02/11/2023.
//

import Foundation
import SwiftUI

struct AddFundsButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Image("bg_btn_addfunds")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipped()
                    
                    Image("ic_btn_addfunds")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 43, height: 47)
                }
                .frame(width: 64, height: 64)
                
                Spacer()
                    .frame(height: 9)

                SatoText(text: "Add funds", style: .subtitle)
            }
        }
    }
}
