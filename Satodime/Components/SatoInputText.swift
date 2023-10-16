//
//  SatoInputText.swift
//  Satodime
//
//  Created by Lionel Delvaux on 16/10/2023.
//

import SwiftUI

struct SatoInputText: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white)
                    .padding(.leading, 20)
            }
            TextField("", text: $text)
                .padding()
                .frame(height: 43)
                .background(Constants.Colors.satoListBackground)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.horizontal, 20)
        }
    }
}
