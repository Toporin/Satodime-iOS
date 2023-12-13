//
//  TokenCellNew.swift
//  Satodime
//
//  Created by Satochip on 04/12/2023.
//

import Foundation
import SwiftUI
import Combine

struct TokenCellNew: View {
    //@ObservedObject var viewModel: TokenCellViewModel
    var tokenAsset: [String: String]
    
    var body: some View {
        HStack {
//            if let mainToken = self.viewModel.mainToken, let cryptoCurrency = CryptoCurrency(shortIdentifier: mainToken) {
//                ZStack {
//                    Circle()
//                        .fill(cryptoCurrency.color)
//                        .frame(width: 50, height: 50)
//                        .padding(5)
//
//                    Image(cryptoCurrency.icon)
//                        .frame(width: 22, height: 22)
//                        .foregroundColor(.white)
//                }
//                .frame(width: 50, height: 50)
//            } else {
//                Image(uiImage: viewModel.image ?? UIImage())
//                    .resizable()
//                    .frame(width: 50, height: 50)
//            }
            //token icon from web api
            if let icon_url = tokenAsset["tokenIconUrl"] {
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
                .onTapGesture(count: 1) {
                    print("tapped on token icon_url!")
                    if let weblink = tokenAsset["tokenExplorerLink"],
                        let weblinkUrl = URL(string: weblink) {
                        UIApplication.shared.open(weblinkUrl)
                    }
                }
            } 
            // token icon from local asset
            else if let icon_path = tokenAsset["tokenIconPath"] {
                //TODO: correct alignment with other cells
                ZStack {
                    Circle()
                        .fill(CryptoCurrency(shortIdentifier: (tokenAsset["symbol"] ?? ""))?.color ?? Color.white) // TODO!
                        .frame(width: 50, height: 50)
                        .padding(5)

                    Image(icon_path) // todo
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
                .onTapGesture(count: 1) {
                    print("tapped on token icon_path!")
                    if let weblink = tokenAsset["tokenExplorerLink"],
                        let weblinkUrl = URL(string: weblink) {
                        UIApplication.shared.open(weblinkUrl)
                    }
                }
                
//                Image(icon_path) // todo
//                    .frame(width: 50, height: 50)
//                    //.foregroundColor(.white)
//                    .clipShape(Circle())
//                    .onTapGesture(count: 1) {
//                        print("tapped on token icon_path!")
//                        if let weblink = tokenAsset["tokenExplorerLink"],
//                            let weblinkUrl = URL(string: weblink) {
//                            UIApplication.shared.open(weblinkUrl)
//                        }
//                    }
                
            } else {
                Image(systemName: "t.circle") // TODO: question mark icon?
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .onTapGesture(count: 1) {
                        print("tapped on token icon_url!")
                        if let weblink = tokenAsset["tokenExplorerLink"],
                            let weblinkUrl = URL(string: weblink) {
                            UIApplication.shared.open(weblinkUrl)
                        }
                    }
            }
            
            
            // show balance
            VStack(alignment: .leading) {
                SatoText(text: tokenAsset["name"] ?? "?", style: .cellSmallTitle)
                    .font(.headline)
                // show balance in token
                //Text((tokenAsset["balance"] ?? "") + " " + (tokenAsset["symbol"] ?? "")) // TODO: clean
                Text(SatodimeUtil.formatBalance(balanceString: tokenAsset["balance"], decimalsString: tokenAsset["decimals"], symbol: tokenAsset["symbol"], maxFractionDigit: 8))
                    .font(
                        Font.custom("Outfit-ExtraLight", size: 12)
                            .weight(.light)
                    )
                    .foregroundColor(.white)
            }
            .padding(.leading, 10)

            Spacer()
            
            // show value in second currency
            //Text((tokenAsset["balance"] ?? "")) // in fiat
            Text(SatodimeUtil.formatBalance(balanceString: tokenAsset["tokenValueInSecondCurrency"], decimalsString: "0", symbol: tokenAsset["secondCurrency"], maxFractionDigit: 2))
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
