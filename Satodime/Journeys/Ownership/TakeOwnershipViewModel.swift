//
//  TakeOwnershipViewModel.swift
//  Satodime
//
//  Created by Lionel Delvaux on 07/10/2023.
//

import Foundation

final class TakeOwnershipViewModel: ObservableObject {
    // MARK: - Literals
    let title = "Take the ownership"
    let subtitle = 
        """
            In order to perform sensitive operations on the card (seal - unseal - reset), you need to take the ownership. 
            This right is revocable and transferable at any time in the application options.
        
            Click Accept to get the ownership right,
            or Cancel to give up.
        """
}
