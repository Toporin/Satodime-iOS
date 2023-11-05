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
    let preferenceService: PPreferencesService = PreferencesService()
    let id = UUID()
    @Published var image: UIImage?
    @Published var name: String
    @Published var cryptoBalance: String
    @Published var fiatBalance: String
    var mainToken: String?
    
    
    private var cancellables = Set<AnyCancellable>()
    let imageUrl: URL?
    
    // MARK: - Lifecycle
    init(imageUri: String, name: String, cryptoBalance: String, fiatBalance: String, mainToken: String? = nil) {
        let imageUrl = URL(string: imageUri)
        self.imageUrl = imageUrl
        self.name = name
        self.cryptoBalance = cryptoBalance
        self.fiatBalance = "\(fiatBalance) \(self.preferenceService.getCurrency())"
        self.mainToken = mainToken
        if mainToken == nil, let imageUrl = self.imageUrl {
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
            if let mainToken = self.viewModel.mainToken, let cryptoCurrency = CryptoCurrency(shortIdentifier: mainToken) {
                ZStack {
                    Circle()
                        .fill(cryptoCurrency.color)
                        .frame(width: 50, height: 50)
                        .padding(5)

                    Image(cryptoCurrency.icon)
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
            } else {
                Image(uiImage: viewModel.image ?? UIImage())
                    .resizable()
                    .frame(width: 50, height: 50)
            }

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
