//
//  NFTCellNew.swift
//  Satodime
//
//  Created by Satochip on 04/12/2023.
//

import Foundation
import SwiftUI
import Combine

struct NftCellNew: View {
    //@ObservedObject var viewModel: TokenCellViewModel
    var nftAsset: [String: String]
    
    var body: some View {
        HStack {
            //token icon
            if let icon_url = nftAsset[""] {
                AsyncImage(
                    url: URL(string: icon_url),
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
                .frame(width: 50, height: 50)
                //.background(Color.white)
                .clipShape(Circle())
                
            } else if let icon_path = nftAsset[""] {
                ZStack {
                    Circle()
                        //.fill(cryptoCurrency.color) // TODO!
                        .frame(width: 50, height: 50)
                        .padding(5)

                    Image(icon_path) // todo
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
                
            } else {
                Image(systemName: "wifi.slash") // todo: question mark icon?
            }
            
            
            
            VStack(alignment: .leading) {
                SatoText(text: nftAsset["name"] ?? "?", style: .cellSmallTitle)
                    .font(.headline)
                Text((nftAsset["balance"] ?? "") + " " + (nftAsset["symbole"] ?? "")) // TODO: clean
                    .font(
                        Font.custom("Outfit-ExtraLight", size: 12)
                            .weight(.light)
                    )
                    .foregroundColor(.white)
            }
            .padding(.leading, 10)

            Spacer()

            Text((nftAsset["balance"] ?? "")) // in fiat
                .font(
                    Font.custom("Outfit-Medium", size: 12)
                        .weight(.medium)
                )
                .foregroundColor(.white)
                .padding(.trailing, 10)
        }
        .background(Constants.Colors.satoListBackground)
    }
}
