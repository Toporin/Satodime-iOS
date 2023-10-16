//
//  TokenCell.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//

import Foundation
import SwiftUI
import Combine

class TokenCellViewModel: ObservableObject {
    // MARK: - Properties
    let id = UUID()
    @Published var image: UIImage?
    @Published var name: String
    @Published var cryptoBalance: String
    @Published var fiatBalance: String
    
    private var cancellables = Set<AnyCancellable>()
    let imageUrl: URL?
    
    // MARK: - Lifecycle
    init(imageUri: String, name: String, cryptoBalance: String, fiatBalance: String) {
        let imageUrl = URL(string: imageUri)
        self.imageUrl = imageUrl
        self.name = name
        self.cryptoBalance = cryptoBalance
        self.fiatBalance = fiatBalance
        if let imageUrl = self.imageUrl {
            self.fetchImage(url: imageUrl)
        }
    }
    
    func fetchImage(url: URL) {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in self?.image = $0 })
            .store(in: &cancellables)
    }
}

struct TokenCell: View {
    let viewModel: TokenCellViewModel

    var body: some View {
        HStack {
            Image(uiImage: viewModel.image ?? UIImage())
                .resizable()
                .frame(width: 50, height: 50)

            VStack(alignment: .leading) {
                SatoText(text: viewModel.name, style: .cellSmallTitle)
                    .font(.headline)
                Text(viewModel.cryptoBalance)
                    .font(
                        Font.custom("Outfit-ExtraLight", size: 12)
                            .weight(.light)
                    )
                    .foregroundColor(.white)
            }
            .padding(.leading, 10)

            Spacer()

            Text(viewModel.fiatBalance)
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
