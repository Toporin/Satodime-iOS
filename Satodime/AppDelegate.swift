//
//  AppDelegate.swift
//  Satodime
//
//  Created by Lionel Delvaux on 26/09/2023.
//

import Foundation
import UIKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let image = UIImage(named: "ic_flipback")!.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = image
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = image
        UINavigationBar.appearance().tintColor = .white
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.clear,
        ], for: .normal)
        FirebaseApp.configure()
        Reachability.shared.startNetworkReachabilityObserver()
        
        // Check if launched via Universal Link
        print("launchOptions: \(launchOptions)")
        if let userActivityDict = launchOptions?[.userActivityDictionary] as? [String: Any],
           let userActivity = userActivityDict["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            print("App launched via Universal Link!")
            handleUniversalLink(userActivity: userActivity, appState: .inactive) // Treat as background/terminated
        } else {
            print("App launched by user!")
        }
        
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print("Received user activity: \(userActivity.activityType), URL: \(userActivity.webpageURL?.absoluteString ?? "none")")
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            print("Processing Universal Link, app state: \(UIApplication.shared.applicationState)")
            let appState = UIApplication.shared.applicationState
            handleUniversalLink(userActivity: userActivity, appState: appState)
            return true
        }
        print("Non-Universal Link activity, ignoring")
        return false
    }
    
    
    // Shared logic to handle Universal Link
    private func handleUniversalLink(userActivity: NSUserActivity, appState: UIApplication.State) {
        guard let url = userActivity.webpageURL else { return }

        // Parse URL (extract website from query param)
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let websiteURLString = components.queryItems?.first(where: { $0.name == "url" })?.value {
            
            if appState == .active {
                // Foreground: Handle silently, no interruption
                print("Universal Link detected in foreground: \(websiteURLString)")
                // Post notification to update UI (e.g., show in a label or log)
                NotificationCenter.default.post(name: .universalLinkDetected, object: websiteURLString)
                // Optional: Prompt user to start NFC scan if tag management needed
            } else {
                // Background or Terminated: Show alert for user choice
                DispatchQueue.main.async {
                    self.showChoiceAlert(websiteURLString: websiteURLString)
                }
            }
        }
    }

    // Show alert for background/terminated cases
    private func showChoiceAlert(websiteURLString: String) {
        let alert = UIAlertController(title: "NFC Tag Detected", message: "Open '\(websiteURLString)' in browser or manage in app?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open in Browser", style: .default) { _ in
            if let url = URL(string: websiteURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Manage in App", style: .default) { _ in
            self.navigateToNFCManager()
        })

        // Present alert from root view controller
        if let topVC = window?.rootViewController {
            // Ensure topVC is visible
            var currentVC = topVC
            while let presentedVC = currentVC.presentedViewController {
                currentVC = presentedVC
            }
            currentVC.present(alert, animated: true)
        }
    }

    // Navigate to NFC management (e.g., show NFC scan view)
    private func navigateToNFCManager() {
        // Example: Navigate to a view controller to start NFCTagReaderSession
        if let navController = window?.rootViewController as? UINavigationController {
            // Replace with your NFC view controller
            // TODO
            //let nfcVC = NFCViewController() // Your NFC scanning view controller
            //navController.pushViewController(nfcVC, animated: true)
        }
        // Or trigger NFC scan directly
        // startNFCReaderSession()
    }
    
    
}

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

// Notification for foreground handling
extension Notification.Name {
    static let universalLinkDetected = Notification.Name("universalLinkDetected")
}
