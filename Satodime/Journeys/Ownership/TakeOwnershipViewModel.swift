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
    
    // MARK: - Literals
    let title = "Take the ownership"
    let subtitle = 
        """
            In order to perform sensitive operations on the card (seal - unseal - reset), you need to take the ownership. 
            This right is revocable and transferable at any time in the application options.
        
            Click **Accept** to get the ownership right,
            or **Cancel** to give up.
        """
    
    init(cardService: PCardService) {
        self.cardService = cardService
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
                self.navigateTo(destination: .goBackHome)
            default:
                break
            }
        }
    }
    
    func cancel() {
        self.navigateTo(destination: .goBackHome)
    }
}
