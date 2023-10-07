//
//  SatoStatusView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 06/10/2023.
//

import Foundation
import SwiftUI

struct SatoStatusView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Image("ic_circle_valid")
                .resizable()
                .frame(width: 6, height: 6)
            
            Image("ic_sato_small")
                .resizable()
                .frame(width: 48, height: 48)
        }
        .frame(width: 54, height: 48)
    }
}
