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
//            SatoText(text: title, style: .lightSubtitle) //subtitleBold
//                .border(Color.pink)
//                .frame(maxWidth: .infinity)
//                .border(Color.blue)
//            //Text(title)
//            
//            Spacer()
//                .border(Color.pink)
            
//            Toggle(title, isOn: $isOn)
//                .toggleStyle(SwitchToggleStyle(tint: Constants.Colors.ledGreen))
//                .onChange(of: isOn) { newValue in
//                    SatoText(text: title, style: .lightSubtitle) //subtitleBold
//                    onToggle(newValue)
//                }
//                .border(Color.pink)
            
            Toggle(isOn: $isOn){
                SatoText(text: title, style: .subtitleBold)
            }
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
