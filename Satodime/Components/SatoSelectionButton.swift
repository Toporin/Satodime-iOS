//
//  SatoSelectionButton.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import SwiftUI

struct SatoSelectionButton: View {
    var mode: ShowPrivateKeyMode

    var body: some View {
        HStack {
            Spacer()
                .frame(width: 18)
            
            SatoText(text: mode.rawValue, style: .cellTitle)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            
            Spacer()
            
            Image("ic_right_arrow_encircled")
                .resizable()
                .frame(width: 31, height: 31)
                .padding(10)
                .foregroundColor(.white)
            
            Spacer()
                .frame(width: 18)
        }
        .frame(height: 71)
        .background(Constants.Colors.cellBackground)
        .cornerRadius(20)
    }
}
