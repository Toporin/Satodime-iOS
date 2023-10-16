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
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                
                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(isOn ? Constants.Colors.ledGreen : .black)
            }
            .onTapGesture {
                self.isOn.toggle()
            }
            
            Spacer()
                .frame(width: 18)
            
            SatoText(text: label, style: .subtitle)
            
            Spacer()
        }
        .padding()
    }
}
