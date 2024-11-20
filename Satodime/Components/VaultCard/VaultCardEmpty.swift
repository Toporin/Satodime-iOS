//
//  VaultCardEmpty.swift
//  Satodime
//
//  Created by Lionel Delvaux on 06/10/2023.
//

import Foundation
import SwiftUI

struct VaultCardEmpty: View {
    // MARK: - Properties
    let id: Int
    var action: () -> Void
    var useFullWidth: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.4), lineWidth: 2)
                .frame(width: useFullWidth ? .infinity : 261, height: 197)
            
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
                    action()
                }) {
                    Image("ic_plus_circle")
                        .resizable()
                        .frame(width: 72, height: 69)
                }
                Spacer()
            }
        }
        // .frame(maxWidth: useFullWidth ? .infinity : 261, minHeight: 197, maxHeight: 197)
    }
}

