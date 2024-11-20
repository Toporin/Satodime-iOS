//
//  ReviewRequestService.swift
//  Satodime
//
//  Created by Lionel Delvaux on 23/02/2024.
//

import Foundation
import StoreKit

class ReviewRequestService {
    private let launchCountKey = "launchCount"
    private let launchesUntilPrompt = 15
    
    func appLaunched() {
        let currentCount = UserDefaults.standard.integer(forKey: launchCountKey)
        if currentCount >= launchesUntilPrompt {
            SKStoreReviewController.requestReviewInCurrentScene()
            UserDefaults.standard.set(0, forKey: launchCountKey)
        } else {
            UserDefaults.standard.set(currentCount + 1, forKey: launchCountKey)
        }
    }
}

extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        let scenes = UIApplication.shared.connectedScenes
        if let windowScene = scenes.first as? UIWindowScene {
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
}
