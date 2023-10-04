//
//  CryptoSelectionCell.swift
//  Satodime
//
//  Created by Lionel Delvaux on 04/10/2023.
//

import Foundation
import SwiftUI

struct CryptoSelectionCell: View {
    let crypto: CryptoCurrency

    var body: some View {
        HStack {
            Spacer()
                .frame(width: 18)
            
            ZStack {
                Circle()
                    .fill(crypto.color)
                    .frame(width: 50, height: 50)
                    .padding(10)

                Image(crypto.icon)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
            
            SatoText(text: "\(crypto.name) (\(crypto.shortIdentifier.uppercased()))", style: .cellTitle)
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
        .frame(height: 84)
        .background(Constants.Colors.cellBackground)
        .cornerRadius(20)
    }
}
