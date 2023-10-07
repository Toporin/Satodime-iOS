//
//  BalanceView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 05/10/2023.
//

import Foundation
import SwiftUI

struct BalanceView: View {
    let title: String
    let balance: String
    let cryptoBalance: String

    var body: some View {
        VStack(alignment: .trailing) {
            SatoText(text: title, style: .subtitle)
            SatoText(text: balance, style: .balanceLarge)
            SatoText(text: cryptoBalance, style: .subtitle)
        }
    }
}
