//
//  LoggerService.swift
//  Satodime
//
//  Created by Lionel Delvaux on 05/11/2023.
//

import Foundation

// MARK: - Protocol
protocol PLoggerService {
    func getLog() -> [String]
    func log(entry: String)
}

// MARK: - Service
final class LoggerService: PLoggerService {
    func getLog() -> [String] {
        let log = UserDefaults.standard.object(forKey: "log") as? String ?? ""
        return log.components(separatedBy: "\n")
    }
    
    func log(entry: String) {
        var currentLog: String = UserDefaults.standard.object(forKey: "log") as? String ?? ""
        currentLog.append("\(entry) \n")
        UserDefaults.standard.set(currentLog, forKey: "log")
    }
    
    
}
