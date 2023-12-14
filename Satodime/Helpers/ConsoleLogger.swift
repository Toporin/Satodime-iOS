//
//  ConsoleLogger.swift
//  Satodime
//
//  Created by Lionel Delvaux on 11/10/2023.
//

import Foundation

// TODO: deprecate
class ConsoleLogger {
    func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
    
    func warning(_ message: String) {
        #if DEBUG
        print("🟡 " + message)
        #endif
    }
    
    func error(_ message: String) {
        #if DEBUG
        print("🔴 " + message)
        #endif
    }
    
    func info(_ message: String) {
        #if DEBUG
        print("🔵 " + message)
        #endif
    }
}

