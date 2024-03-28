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
    @EnvironmentObject var nftPreviewHandler: NftPreviewHandler
    
    var nftAsset: [String: String]
    
    var body: some View {
        HStack {
            //token icon
            if let iconUrl = nftAsset["nftImageUrl"] {
                AsyncImage(
                    url: URL(string: SatodimeUtil.getNftImageUrlString(link: iconUrl)),
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
                .onTapGesture(count: 1) {
                    if let imageUrl = nftAsset["nftImageUrl"] {
                        self.nftPreviewHandler.nftImageUrl = imageUrl
                    }
                    if let weblink = nftAsset["nftExplorerLink"] {
                        self.nftPreviewHandler.nftExplorerUrl = weblink
                    }
                    if let name = nftAsset["nftName"] {
                        self.nftPreviewHandler.nftName = name
                    }
                    self.nftPreviewHandler.shouldShowNftPreview = true
                }
                
            } else {
                Image(systemName: "n.circle") // todo: question mark icon?
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .onTapGesture(count: 1) {
                    if let imageUrl = nftAsset["nftImageUrl"] {
                        self.nftPreviewHandler.nftImageUrl = imageUrl
                    }
                    if let weblink = nftAsset["nftExplorerLink"] {
                        self.nftPreviewHandler.nftExplorerUrl = weblink
                    }
                    if let name = nftAsset["nftName"] {
                        self.nftPreviewHandler.nftName = name
                    }
                    self.nftPreviewHandler.shouldShowNftPreview = true
                }
            }
            
            // NAME & BALANCE
            VStack(alignment: .leading) {
                SatoText(text: nftAsset["nftName"] ?? "?", style: .cellSmallTitle)
                    .font(.headline)
                Text((SatodimeUtil.formatBalance(balanceString: nftAsset["balance"], decimalsString: nftAsset["decimals"], symbol: nftAsset["symbols"])))
                    .font(
                        Font.custom("Outfit-ExtraLight", size: 12)
                            .weight(.light)
                    )
                    .foregroundColor(.white)
            }
            .padding(.leading, 10)

            Spacer()
            
            // TODO: value in second currency (not supported yet)
//            Text((nftAsset["balance"] ?? "")) // in fiat
//                .font(
//                    Font.custom("Outfit-Medium", size: 12)
//                        .weight(.medium)
//                )
//                .foregroundColor(.white)
//                .padding(.trailing, 10)
        }
        .background(Constants.Colors.satoListBackground)
    }
}
