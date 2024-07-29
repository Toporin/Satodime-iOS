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
    @Binding var showNoNetworkAlert: Bool
    
    @State private var showingSafariView = false
    var urlHandler = UrlHandler()
    
    private func openUrl(_ url: SatochipURL) {
        if let urlToOpen = url.url {
            self.urlHandler.urlToOpenInApp = urlToOpen
            self.showingSafariView = true
        }
    }
    
    var body: some View {
        if cardState.vaultArray.isEmpty {
            VStack {
                
                Spacer()
                
                ScanButton {
                    Task {
                        let networkDataFetchResult = await cardState.executeQuery()
                        switch networkDataFetchResult {
                        case .success:
                            break
                        case .failure:
                            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                                self.showNoNetworkAlert = true
                            }
                        }
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
                        self.urlHandler.urlToOpenInApp = weblinkUrl
                        self.showingSafariView = true
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
            .sheet(isPresented: $showingSafariView) {
                if let urlToOpenInApp = self.urlHandler.urlToOpenInApp {
                    SafariView(url: urlToOpenInApp)
                }
            }
        }
    }
}
