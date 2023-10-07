//
//  SealStatus.swift
//  Satodime
//
//  Created by Lionel Delvaux on 05/10/2023.
//

import Foundation
import SwiftUI

enum SealStatus {
    case sealed
    case unsealed
}

struct SealStatusView: View {
    let status: SealStatus

    var body: some View {
        HStack {
            Image(status == .sealed ? "ic_lock_sealed" : "ic_lock_unsealed")
                .resizable()
                .frame(width: 9, height: 13)
            
            Text(status == .sealed ? "Sealed" : "Unsealed")
                .foregroundColor(status == .sealed ? Constants.Colors.sealedStatusText : Constants.Colors.unsealedStatusText)
            
            Spacer()
        }
    }
}
