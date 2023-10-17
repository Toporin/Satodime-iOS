//
//  SatoTabView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//
import SwiftUI
import Combine

// MARK: - SatoTabView

enum SelectedTab {
    case token, nft, history
}

struct SatoTabView: View {
    @State private var selectedTab: SelectedTab = .token
    @ObservedObject var nftListViewModel: NFTListViewModel
    @ObservedObject var tokenListViewModel: TokenListViewModel
    @Binding var canSelectNFT: Bool

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
                                        
                    Button(action: {
                        selectedTab = .history
                    }) {
                        VStack {
                            SatoText(text: "History", style: .subtitleBold)
                            ZStack {
                                Rectangle().frame(height: 2).foregroundColor(Constants.Colors.separator)
                                if selectedTab == .history {
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
                    TokenListView(viewModel: self.tokenListViewModel)
                        .background(Color.clear)
                case .nft:
                    NFTListView(viewModel: self.nftListViewModel)
                        .background(Color.clear)
                case .history:
                    HistoryListView()
                        .background(Color.clear)
                }
            }
            .background(Color.clear)
        }
    }
}

// MARK: - TokenListView

class TokenListViewModel: ObservableObject {
    @Published var cellViewModels = [TokenCellViewModel]()
    
    func populateCellViewModels(from items: [TokenCellViewModel]) {
        self.cellViewModels = items
    }
}

struct TokenListView: View {
    @ObservedObject var viewModel: TokenListViewModel

    var body: some View {
        List(viewModel.cellViewModels, id: \.id) { token in
            TokenCell(viewModel: token)
                .listRowBackground(Constants.Colors.satoListBackground)
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
}

// MARK: - NFTListView

class NFTListViewModel: ObservableObject {
    @Published var cellViewModels = [NFTCellViewModel]()
    
    func populateCellViewModels(from urlList: [URL]) {
        self.cellViewModels = urlList.map { NFTCellViewModel(imageUrl: $0) }
    }
}

struct NFTListView: View {
    @ObservedObject var viewModel: NFTListViewModel
    
    var body: some View {
        List(viewModel.cellViewModels, id: \.imageUrl) { cellVM in
            NFTCell(viewModel: cellVM)
                .listRowBackground(Constants.Colors.satoListBackground)
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
}

// MARK: - HistoryListView

class HistoryListViewModel: ObservableObject {
    @Published var cellViewModels = [HistoryCellViewModel]()
    
    func populateCellViewModels(from items: [HistoryCellViewModel]) {
        self.cellViewModels = items
    }
}

struct HistoryListView: View {
    let historyItems: [HistoryCellViewModel] = []

    var body: some View {
        List(historyItems, id: \.id) { historyItem in
            HistoryCell(historyItem: historyItem)
                .listRowBackground(Constants.Colors.satoListBackground)
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
}


