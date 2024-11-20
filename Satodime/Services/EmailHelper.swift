//
//  EmailService.swift
//  Satodime
//
//  Created by Lionel Delvaux on 23/02/2024.
//

import Foundation
import SwiftUI

class EmailHelper {
    struct SupportEmail {
        let toAddress: String = "support@satochip.io"
        let subject: String = "Satodime-iOS - Feedback"
        var body: String { """
        Application Name: \(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown")
        iOS Version: \(UIDevice.current.systemVersion)
        Device Model: \(UIDevice.current.model)
        App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "no app version")
        App Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "no app build version")
        
        Please describe your issue / feedback below
        ---------------------------------------------
      
      """}
        
        func send(openURL: OpenURLAction) {
            let replacedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
            let replacedBody = body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
            let urlString = "mailto:\(toAddress)?subject=\(replacedSubject)&body=\(replacedBody)"
            guard let url = URL(string: urlString) else { return }
            openURL(url) { accepted in
                if !accepted {
                    print("Device doesn't support email.\n \(body)")
                }
            }
        }
    }
}
