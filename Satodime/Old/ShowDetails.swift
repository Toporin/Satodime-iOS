//
//  ShowDetails.swift
//  Satodime for iOS
//
//  Created by Satochip on 21/01/2023.
//  Copyright © 2023 Satochip S.R.L.
//

import SwiftUI
import QRCode
import SwiftCryptoTools

struct ShowDetails: View {
    
    @EnvironmentObject var reader: NfcReader
    @State private var showPrivkey = false
    var item: VaultItem
    var index: Int
    
    static var gradiantArray = [[Color("Color_gold"), Color("Color_gold")], [.cyan, .green], [.orange, .red]]
    
    var body: some View {
        
        Text("Details for vault #\(index)")
            .foregroundColor(.black)
            .font(.title)
            .padding(20)
            .background(
                LinearGradient(
                    colors: ShowDetails.gradiantArray[Int(item.keyslotStatus.status)%3],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
        
        ScrollView {
            
//            CustomGroup(title: "Key info") {
//                //Text("Status: \(item.getStatusString())")
//                Text("Status: \(String(localized: String.LocalizationValue(stringLiteral: item.getStatusString())))")
//                //Text("Asset type: \(item.getAssetString())")
//                Text("Asset type: \(String(localized: String.LocalizationValue(stringLiteral: item.getAssetString())))")
//                Text("Pubkey: \(item.getPublicKeyString())")
//            }
            
            CustomGroup(title: "Coin info") {
                Text("Blockchain: \(item.coin.displayName)")
                Text("Address: \(item.address)")
                Text("Balance: \(item.getCoinBalanceString())")
                // buttons
                ClickablesIcons(textClipboard: item.address, textQR: item.address, linkURL: item.addressUrl)
            }
            
            // token
            if let tokenList = item.tokenList {
                CustomGroup(title: "token list") {
                    if let tokenValue = item.totalTokenValueInSecondCurrency {
                        if let currency = item.selectedSecondCurrency {
                            Text("token value: \(tokenValue) \(currency)")
                        }
                    }
                    ForEach(tokenList, id: \.self) { token in
                        if token["type"]=="token"{
                            if let name = token["name"] {
                                Text("Asset name: \(name)")
                            }
                            if let contract = token["contract"] {
                                Text("Asset contract: \(contract)")
                            }
                            Text("Balance: \(item.getTokenBalanceString(tokenData: token))")
                            if let tokenIconUrl = token["tokenIconUrl"] {
                                HStack {
                                    Spacer()
                                    AsyncImage(
                                        url: URL(string: tokenIconUrl),
                                        transaction: Transaction(animation: .easeInOut)
                                    )
                                    { phase in
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
                                    .frame(width: 100, height: 100)
                                    Spacer()
                                }
                            } else {
                                Image(systemName: "dollarsign.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    //.foregroundColor(Color("Color_foreground"))
                            }
                            
                        }
                    }
                }
            }//token
            
            // NFT
            if let nftList = item.nftList {
                CustomGroup(title: "nft list") {
                    ForEach(nftList, id: \.self) { nft in
                        if let name = nft["name"] {
                            Text("Name: \(name)")
                        }
                        if let contract = nft["contract"] {
                            Text("Contract: \(contract)")
                        }
                        if let tokenid = nft["tokenid"] {
                            Text("Tokenid: \(tokenid)")
                        }
                        if let balance = nft["balance"] {
                            Text("Balance: \(balance)")
                        }
//                        if let decimals = nft["decimals"] {
//                            Text("Decimals: \(decimals)")
//                        }
//                        if let nftDescription = token["nftDescription"] {
//                            Text("nftDescription: \(nftDescription)")
//                        }
                        if let nftImageUrl = nft["nftImageUrl"] {
                            HStack {
                                Spacer()
                                AsyncImage(
                                    url: URL(string: item.getNftImageUrlString(link: nftImageUrl)),
                                    transaction: Transaction(animation: .easeInOut)
                                )
                                { phase in
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
                                .frame(width: 250, height: 250)
                                Spacer()
                            }
                        }//if
                    }
                }
            }//NFT
            
            if item.keyslotStatus.status == 0x02 {
                CustomGroup(title: "Private info") {
                    Button(action:{
                        print("Button show privkey")
                        print("showPrivkey: \(showPrivkey)")
                        if showPrivkey {
                            showPrivkey = false
                        } else {
                            showPrivkey = true
                            // fetch private info from card if not already available
                            // also todo: check if isOwner?
                            if (reader.vaultArray[index].privkey == nil) {
                                let actionParams = ActionParams(index: UInt8(index), action: "private")
                                reader.scanForAction(actionParams: actionParams)
                            }
                        }
                    }){
                        if showPrivkey {
                            Text("Hide private key")
                        }
                        else {
                            Text("Show private key")
                        }
                    }
                    if showPrivkey {
                        if (reader.vaultArray[index].privkey != nil) {
                            Text("Privkey: \(reader.vaultArray[index].getPrivateKeyString())")
                            ClickablesIcons(textClipboard: reader.vaultArray[index].getPrivateKeyString(), textQR: reader.vaultArray[index].getPrivateKeyString(), linkURL: nil)
                            Text("WIF: \(reader.vaultArray[index].getWifString())")
                            ClickablesIcons(textClipboard: reader.vaultArray[index].getWifString(), textQR: reader.vaultArray[index].getWifString(), linkURL: nil)
                            Text("Entropy: \(reader.vaultArray[index].getEntropyString())")
                            ClickablesIcons(textClipboard: reader.vaultArray[index].getEntropyString(), textQR: reader.vaultArray[index].getEntropyString(), linkURL: nil)
                        } else {
                            Text("Privkey is not available! \nAre you owner?")
                        }
                    }
                }
            }
        }
    }
    
    func getColorFromStatus(status: UInt8) -> String {
        switch status {
        case 1:
            return "Color_green"
        case 2:
            return "Color_red"
        default:
            return "Color_gold"
        }
    }
}

struct CustomGroup<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack {
            Text(LocalizedStringKey(title))
                .font(.title)
            VStack(alignment: .leading) {
                content()
            }
            //.background(Color.yellow)
            //.cornerRadius(8)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("Color_frame"), lineWidth: 4)
            )
        }
    }
} // CustomGroup

struct ClickablesIcons: View {
    
    @State private var showQR = false
    let textClipboard: String?
    let textQR: String?
    let linkURL: URL?
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                // copy to clipboard
                if textClipboard != nil {
                    Image(systemName: "doc.on.doc")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                        .foregroundColor(Color("Color_gold"))
                        .onTapGesture(count: 1) {
                            UIPasteboard.general.string = textClipboard
                        }
                }
                // show qrcode
                if textQR != nil {
                    Image(systemName: "qrcode")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                        .foregroundColor(Color("Color_gold"))
                        .onTapGesture(count: 1) {
                            showQR.toggle()
                        }
                }
                // open external link
                if linkURL != nil {
                    Link(destination: linkURL!, label: {
                        Image(systemName: "arrow.up.forward.app")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .foregroundColor(Color("Color_gold"))
                        //.resizable()
                        //.frame(width: 30, height: 30)
                    })
                }
                Spacer()
            } // HStack
            if showQR {
                if let textQR = textQR,
                   let cgImage = getQRfromText(text: textQR) {
                    Spacer()
                    Image(uiImage: UIImage(cgImage: cgImage))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, alignment: .center)
//                    QRCodeViewUI(
//                       content: textQR,
//                       foregroundColor: UIColor(Color("Color_gold")).cgColor, //CGColor(srgbRed: 1, green: 0.8, blue: 0.6, alpha: 1.0),
//                       backgroundColor: CGColor(srgbRed: 0.2, green: 0.2, blue: 0.8, alpha: 1.0),
//                       pixelStyle: QRCode.PixelShape.RoundedPath(cornerRadiusFraction: 0.7, hasInnerCorners: true),
//                       eyeStyle: QRCode.EyeShape.RoundedRect()
//                    )
                    Spacer()
                    
                    
                } else {
                    Spacer()
                    Image(systemName: "photo")
                    Spacer()
                }
            }
        } // VStack
    }
    
    public func getQRfromText(text: String) -> CGImage? {
        let doc = QRCode.Document(utf8String: text, errorCorrection: .high)
        doc.design.foregroundColor(UIColor(Color("Color_gold")).cgColor)
        doc.design.backgroundColor(UIColor(Color("Color_background")).cgColor)
        let generated = doc.cgImage(CGSize(width: 250, height: 250))
        return generated
    }
    
} // clickablesIcons


struct ShowDetails_Previews: PreviewProvider {
    static var previews: some View {
        //ShowDetails(item: VaultItem)
        Text("Todo")
    }
}
