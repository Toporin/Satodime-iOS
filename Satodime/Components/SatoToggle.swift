//
//  SatoToggle.swift
//  Satodime
//
//  Created by Lionel Delvaux on 04/10/2023.
//

import Foundation
import SwiftUI

struct SatoToggle: View {
    @Binding var isOn: Bool
    var label: String
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 2)
                    .background(isOn ? Constants.Colors.ledGreen : .clear)
                    .clipShape(Circle())
                    .frame(width: 28, height: 28)
            }
            .onTapGesture {
                self.isOn.toggle()
            }
            
            Spacer()
                .frame(width: 18)
            
            SatoText(text: label, style: .subtitle)
                .lineLimit(nil)
            
            Spacer()
        }
        .padding()
    }
}
