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
    var isMoreInfoBtnVisible: Bool = true
    var imageUrl: String? = nil
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
            
            if let imageUrl = alert.imageUrl {
                AsyncImage(
                    url: URL(string: SatodimeUtil.getNftImageUrlString(link: imageUrl)),
                    transaction: Transaction(animation: .easeInOut)
                ) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .transition(.scale(scale: 0.1, anchor: .center))
                    case .failure:
                        Image(systemName: "wifi.slash")
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(16)
                
                Spacer()
                    .frame(height: 16)
            }
            
            VStack {
                if alert.isMoreInfoBtnVisible {
                    Button(action: {
                        alert.buttonAction()
                        isPresented = false
                    }) {
                        Text(alert.buttonTitle)
                            .padding(.horizontal, Constants.Dimensions.firstButtonPadding)
                            .padding()
                            .background(Constants.Colors.informButtonBackground)
                            .foregroundColor(.white)
                            .cornerRadius(24)
                    }
                    Spacer()
                        .frame(height: 16)
                }
                    
                Button(action: {
                    isPresented = false
                }) {
                    Text(String(localized: "close"))
                        .padding(.horizontal, Constants.Dimensions.secondButtonPadding)
                        .padding()
                        .background(Constants.Colors.ledBlue)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                }
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
                .frame(height: 16)
        }
        .padding()
        .background(Color(hex: 0x27273C))
        .cornerRadius(20)
        .shadow(radius: 10)
    }// body
}
