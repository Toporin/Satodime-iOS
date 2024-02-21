//
//  EmptyScanStateOverlay.swift
//  Satodime
//
//  Created by Lionel Delvaux on 21/02/2024.
//

import Foundation
import SwiftUI

struct EmptyScanStateOverlay: View {
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    
    @Binding var showNotOwnerAlert: Bool
    @Binding var showNotAuthenticAlert: Bool
    @Binding var showTakeOwnershipAlert: Bool
    
    var body: some View {
        if cardState.vaultArray.isEmpty {
            VStack {
                
                Spacer()
                
                ScanButton {
                    Task {
                        await cardState.executeQuery()
                    }
                    // reset flag when scanning a new card
                    showTakeOwnershipAlert = true
                    showNotOwnerAlert = true
                    showNotAuthenticAlert = true
                }
                
                Spacer()
                
                // Buy button
                // TODO: put in separate file
                Button(action: {
                    if let weblinkUrl = URL(string: "https://satochip.io/product/satodime/") {
                        UIApplication.shared.open(weblinkUrl)
                    }
                }) {
                    HStack {
                        Text("dontHaveASatodime")
                        Image(systemName: "cart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(20)
            }
        }
    }
}
