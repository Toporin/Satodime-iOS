//
//  SettingsToggle.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation
import SwiftUI

struct SettingsToggle: View {
    let title: String
    let backgroundColor: Color
    @Binding var isOn: Bool
    var onToggle: (Bool) -> Void
    
    var body: some View {
        HStack {
            SatoText(text: title, style: .subtitleBold)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Constants.Colors.ledGreen))
                .onChange(of: isOn) { newValue in
                    onToggle(newValue)
                }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 55, maxHeight: 55)
        .background(backgroundColor)
        .cornerRadius(20)
    }
}
