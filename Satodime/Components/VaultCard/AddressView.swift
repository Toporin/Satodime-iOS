//
//  AddressView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 05/10/2023.
//

import Foundation
import SwiftUI

struct AddressView: View {
    let text: String
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            
            SatoText(text: text, style: .addressText, alignment: .trailing)
                .lineLimit(1)
                .frame(maxWidth: 100, alignment: .trailing)
                .clipped()
            
            Spacer()
                .frame(width: 13)
            
            Button(action: action) {
                Image("ic_copy_clipboard")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
