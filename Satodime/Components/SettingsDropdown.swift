//
//  SettingsDropdown.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation
import SwiftUI

struct SelectionSheet: View {
    @Binding var isPresented: Bool
    var choices: [String]
    var selectionHandler: (String) -> Void

    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Spacer()
                    .frame(height: 37)
                
                ForEach(choices, id: \.self) { choice in
                    Button(action: {
                        selectionHandler(choice)
                        isPresented = false
                    }) {
                        SatoText(text: choice, style: .subtitle)
                            .padding()
                    }
                }
                Spacer()
            }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
        }
    }
}

struct SettingsDropdown: View {
    let title: String
    let backgroundColor: Color
    @Binding var selectedValue: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                SatoText(text: title, style: .subtitle)
                    .lineLimit(1)
                
                Spacer()
                
                Text(selectedValue)
                    .foregroundColor(Constants.Colors.ledGreen)
                    .lineLimit(1)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 55, maxHeight: 55)
            .background(backgroundColor)
            .cornerRadius(20)
        }
    }
}
