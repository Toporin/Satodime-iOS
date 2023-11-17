//
//  TakeOwnershipViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 07/10/2023.
//

import Foundation

final class TakeOwnershipViewModel: BaseViewModel {
    // MARK: - Properties
    let logger = ConsoleLogger()
    let cardService: PCardService
    var cardVaults: CardVaults
    var destinationOnClose: NavigationState?
    
    // MARK: - Literals
    let title = "takeTheOwnershipTitle"
    let subtitle = "takeTheOwnershipDescription"
    
    init(cardService: PCardService, cardVaults: CardVaults, viewStackHandler: ViewStackHandler? = nil, destinationOnClose: NavigationState? = nil) {
        self.cardService = cardService
        self.cardVaults = cardVaults
        super.init()
        if let viewStackHandler = viewStackHandler {
            self.viewStackHandler = viewStackHandler
        }
        self.destinationOnClose = destinationOnClose
    }
    
    func acceptCard() {
        self.cardService.acceptCard { [weak self] status in
            guard let self = self else {
                return
            }
            
            switch status {
            case .unknown:
                logger.error("Unknown status on acceptCard()")
            case .readingError(error: let error):
                logger.error("Error on acceptCard() : \(error)")
            case .cardAccepted:
                DispatchQueue.main.async {
                    self.cardVaults.isOwner = true
                    self.navigateTo(destination: .goBackHome)
                }
            default:
                break
            }
        }
    }
    
    func cancel() {
        if let destinationOnClose = destinationOnClose {
            self.navigateTo(destination: destinationOnClose)
        } else {
            self.navigateTo(destination: .goBackHome)
        }
    }
}
