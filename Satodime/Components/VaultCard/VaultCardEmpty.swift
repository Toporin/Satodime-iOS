//
//  VaultCardEmpty.swift
//  Satodime
//
//  Created by Lionel Delvaux on 06/10/2023.
//

import Foundation
import SwiftUI

struct VaultCardEmpty: View {
    let id: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.4), lineWidth: 2)
                .frame(width: 261, height: 197)
            
            VStack {
                HStack {
                    SatoText(text: "0\(id+1)", style: .slotTitle)
                    Spacer()
                }.padding(20)
                Spacer()
            }
            
            VStack {
                Spacer()
                Button(action: {
                    
                }) {
                    Image("ic_plus_circle")
                        .resizable()
                        .frame(width: 72, height: 69)
                }
                Spacer()
            }
        }
    }
}

