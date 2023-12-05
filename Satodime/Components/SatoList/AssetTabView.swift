//
//  AssetTabView.swift
//  Satodime
//
//  Created by Satochip on 04/12/2023.
//

import SwiftUI
import Combine

// MARK: - SatoTabView

struct AssetTabView: View {
    
    @EnvironmentObject var cardState: CardState
    
    //@ObservedObject var nftListViewModel: NFTListViewModel
    //@ObservedObject var tokenListViewModel: TokenListViewModel
    
    @State private var selectedTab: SelectedTab = .token
    //@Binding var canSelectNFT: Bool
    
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
                            SatoText(text: "Token", style: .subtitleBold)
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
                            SatoText(text: "NFT", style: .subtitleBold)
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
                    TokenListViewNew(tokenList: getTokenList()) // TODO: add native coin in args
                        .background(Color.clear)
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
    
    func getTokenList() -> [[String:String]] {
        if cardState.vaultArray.count > index {
            return cardState.vaultArray[index].tokenList ?? [[String:String]]()
        }
        return [[String:String]]()
    }
    
    func getNftList() -> [[String:String]] {
        if cardState.vaultArray.count > index {
            return cardState.vaultArray[index].nftList ?? [[String:String]]()
        }
        return [[String:String]]()
    }
    
}

// MARK: - TokenListView

//class TokenListViewModel: ObservableObject {
//    @Published var cellViewModels = [TokenCellViewModel]()
//    
//    func populateCellViewModels(from items: [TokenCellViewModel]) {
//        self.cellViewModels = items
//    }
//}

struct TokenListViewNew: View {
    //@ObservedObject var viewModel: TokenListViewModel
    var tokenList: [[String: String]]
    //var tokenNative: [String:String] // todo
    
    var body: some View {
        // todo: add native token (coin)
        List(tokenList, id: \.self) { token in
            TokenCellNew(tokenAsset: token)
                .listRowBackground(Constants.Colors.satoListBackground)
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
}

// MARK: - NFTListView

//class NFTListViewModel: ObservableObject {
//    @Published var cellViewModels = [NFTCellViewModel]()
//    
//    func populateCellViewModels(from urlList: [URL]) {
//        self.cellViewModels = urlList.map { NFTCellViewModel(imageUrl: $0) }
//    }
//}

struct NftListViewNew: View {
    //@ObservedObject var viewModel: NFTListViewModel
    var nftList: [[String: String]]
    
    var body: some View {
        //List(viewModel.cellViewModels, id: \.imageUrl) { cellVM in // imageUrl may not be unique!!
        List(nftList, id: \.self) { nft in
            NftCellNew(nftAsset: nft)
                .listRowBackground(Constants.Colors.satoListBackground)
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
}



