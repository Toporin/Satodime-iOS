//
//  TransferOwnershipViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation
import Foundation

final class TransferOwnershipViewModel: BaseViewModel {
    // MARK: - Properties
    let logger = ConsoleLogger()
    let cardService: PCardService
    
    // MARK: - Literals
    let title = "Transfer ownership"
    let subtitle =
        "Please note!\n\nThis operation releases the ownership of the card. The next person to scan the card becomes its owner.\n\nOnly the owner of the card can perform sensitive operations (seal-unseal-reset) on the mobile device.\n\nClick **Transfer** to continue,\nor **Cancel** to give up."
    let transferButtonTitle = "Transfer"
    
    init(cardService: PCardService) {
        self.cardService = cardService
    }
    
    func transferCard() {
        self.cardService.transferOwnership { [weak self] status in
            guard let self = self else {
                return
            }
            
            switch status {
            case .unknown:
                logger.error("Unknown status on acceptCard()")
            case .readingError(error: let error):
                logger.error("Error on acceptCard() : \(error)")
            case .transfer:
                DispatchQueue.main.async {
                    self.viewStackHandler?.refreshVaults = .clear
                    self.navigateTo(destination: .goBackHome)
                }
            default:
                break
            }
        }
    }
}
