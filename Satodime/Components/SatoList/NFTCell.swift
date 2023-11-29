//
//  NFTCell.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import SwiftUI
import Combine

class NFTCellViewModel: ObservableObject {
    // MARK: - Properties
    @Published var image: UIImage?
    private var cancellables = Set<AnyCancellable>()
    let imageUrl: URL
    let uid = UUID()
    
    // MARK: - Lifecycle
    init(imageUrl: URL) {
        self.imageUrl = imageUrl
        fetchImage()
    }
    
    func fetchImage() {
        URLSession.shared.dataTaskPublisher(for: imageUrl)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in self?.image = $0 })
            .store(in: &cancellables)
    }
}

struct NFTCell: View {
    // MARK: - Properties
    @ObservedObject var viewModel: NFTCellViewModel
    
    var body: some View {
        if let image = viewModel.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipped()
        } else {
            Rectangle() // Placeholder while loading
                .fill(Color.gray)
                .frame(width: 90, height: 90)
        }
    }
}
