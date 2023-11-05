//
//  SealButton.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//

import SwiftUI

struct UnsealButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Image("bg_seal_clear")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipped()
                    
                    Image("ic_lock_white")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 27, height: 39)
                }
                .frame(width: 64, height: 64)
                
                Spacer()
                    .frame(height: 9)

                SatoText(text: "Unseal", style: .subtitle, forcedColor: .white)
            }
        }
    }
}
