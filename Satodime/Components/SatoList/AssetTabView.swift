//
//  AssetTabView.swift
//  Satodime
//
//  Created by Satochip on 04/12/2023.
//

import SwiftUI
import Combine

// MARK: - AssetTabView

enum SelectedTab {
    case token, nft//, history
}

struct AssetTabView: View {
    
    @EnvironmentObject var cardState: CardState
    @State private var selectedTab: SelectedTab = .token
    
    var index: Int
    var canSelectNFT: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundColor(Constants.Colors.satoListBackground)
                .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.all)
                
            VStack {
                HStack(spacing: 0) {
                    Button(action: {
                        selectedTab = .token
                    }) {
                        VStack {
                            SatoText(text: "Token (\(getTokenNumber()))", style: .subtitleBold)
                            ZStack {
                                Rectangle().frame(height: 2).foregroundColor(Constants.Colors.separator)
                                if selectedTab == .token {
                                    Rectangle()
                                        .frame(width: 61, height: 4)
                                        .foregroundColor(Constants.Colors.ledGreen)
                                }
                            }
                        }
                    }
                                        
                    Button(action: {
                        if self.canSelectNFT {
                            selectedTab = .nft
                        }
                    }) {
                        VStack {
                            SatoText(text: "NFT (\(getNftNumber()))", style: .subtitleBold)
                                .opacity(self.canSelectNFT ? 1 : 0.3)
                            ZStack {
                                Rectangle().frame(height: 2).foregroundColor(Constants.Colors.separator)
                                if selectedTab == .nft {
                                    Rectangle()
                                        .frame(width: 61, height: 4)
                                        .foregroundColor(Constants.Colors.ledGreen)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 33)
                
                Divider().opacity(0)
                
                switch selectedTab {
                case .token:
                    TokenListViewNew(tokenList: getTokenList(), tokenNative: getTokenNative() )
                        .background(Color.clear)// TODO: different backgrounds for token & nft?
                case .nft:
                    NftListViewNew(nftList: getNftList())
                        .background(Color.clear)
                /*case .history:
                    HistoryListView()
                        .background(Color.clear)*/
                }
            }
            .background(Color.clear)
        }
    } // body
    
    func convertOptDoubleToString(balanceDouble: Double?) -> String {
        if let balanceDouble = balanceDouble {
            return String(balanceDouble)
        } else {
            return "" // if nil
        }
    }
    
    func getTokenNumber() -> Int {
        if cardState.vaultArray.count > index {
            return 1 + (cardState.vaultArray[index].tokenList?.count ?? 0)
        }
        return 0
    }
    
    func getNftNumber() -> Int {
        if cardState.vaultArray.count > index {
            return cardState.vaultArray[index].nftList?.count ?? 0
        }
        return 0
    }
    
    func getTokenList() -> [[String:String]] {
        if cardState.vaultArray.count > index {
            return cardState.vaultArray[index].tokenList ?? [[String:String]]()
        }
        return [[String:String]]()
    }
    
    func getTokenNative() -> [String:String] {
        if index < cardState.vaultArray.count {
            let address = cardState.vaultArray[index].address
            var coinDict = [String:String]()
            coinDict["name"] = cardState.vaultArray[index].coin.displayName
            coinDict["symbol"] = cardState.vaultArray[index].coin.coinSymbol
            coinDict["type"] = "coin" 
            coinDict["balance"] = convertOptDoubleToString(balanceDouble: cardState.vaultArray[index].balance)
            coinDict["decimals"] = "0"
            coinDict["tokenIconPath"] = cardState.vaultArray[index].coinMeta.icon
            coinDict["tokenExplorerLink"] = cardState.vaultArray[index].coin.getAddressWebLink(address: address)
            coinDict["tokenValueInSecondCurrency"] = convertOptDoubleToString(balanceDouble: cardState.vaultArray[index].coinValueInSecondCurrency)
            coinDict["secondCurrency"] = cardState.vaultArray[index].selectedSecondCurrency
            return coinDict
        }
        return [String:String]()
    }
    
    func getNftList() -> [[String:String]] {
        if cardState.vaultArray.count > index {
            return cardState.vaultArray[index].nftList ?? [[String:String]]()
        }
        return [[String:String]]()
    }
    
}

// MARK: - TokenListView

struct TokenListViewNew: View {
    var tokenList: [[String: String]]
    var tokenNative: [String:String] // todo
    
    var body: some View {
        VStack {
            // First add native token (coin)
            TokenCellNew(tokenAsset: tokenNative)
                .padding([.leading, .trailing], 20)
            // Then add the list of tokens
            List(tokenList, id: \.self) { token in
                TokenCellNew(tokenAsset: token)
                    .listRowBackground(Constants.Colors.satoListBackground)
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
        }
    }
}

// MARK: - NFTListView

struct NftListViewNew: View {
    var nftList: [[String: String]]
    
    var body: some View {
        List(nftList, id: \.self) { nft in
            NftCellNew(nftAsset: nft)
                .listRowBackground(Constants.Colors.satoListBackground)
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
}



