//
//  SatoAlert.swift
//  Satodime
//
//  Created by Lionel Delvaux on 31/10/2023.
//

import Foundation
import SwiftUI

struct SatoAlert {
    var title: String
    var message: String
    var buttonTitle: String
    var buttonAction: () -> Void
}

struct SatoAlertView: View {
    @Binding var isPresented: Bool
    var alert: SatoAlert
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 16)
            SatoText(text: alert.title, style: .title)
                .font(.headline)
            Spacer()
                .frame(height: 16)
            SatoText(text: alert.message, style: .subtitle)
                .font(.body)
            Spacer()
                .frame(height: 16)
            
            VStack {
                Button(action: {
                    alert.buttonAction()
                    isPresented = false
                }) {
                    Text(alert.buttonTitle)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.Colors.informButtonBackground)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                }
                Spacer()
                    .frame(height: 16)
                Button(action: {
                    isPresented = false
                }) {
                    Text(String(localized: "close"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.Colors.ledBlue)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                }
            }
            
            Spacer()
                .frame(height: 16)
        }
        .padding()
        .background(Color(hex: 0x27273C))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
