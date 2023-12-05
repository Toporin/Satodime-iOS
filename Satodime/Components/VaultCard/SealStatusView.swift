//
//  SealStatus.swift
//  Satodime
//
//  Created by Lionel Delvaux on 05/10/2023.
//

import Foundation
import SwiftUI

public enum SealStatus { // TODO: move
    case uninitialized
    case sealed
    case unsealed
}

struct SealStatusView: View { // TODO: rename to VaultStatusView
    let status: SealStatus

    var body: some View {
        HStack {
            Image(status == .sealed ? "ic_lock_sealed" : "ic_lock_unsealed")
                .resizable()
                .frame(width: 9, height: 13)
            
            Text(status == .sealed ? String(localized: "sealed") : String(localized: "unsealed"))
                .foregroundColor(status == .sealed ? Constants.Colors.sealedStatusText : Constants.Colors.unsealedStatusText)
            
            Spacer()
        }
    }
}
