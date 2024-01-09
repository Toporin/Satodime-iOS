//
//  LoggerService.swift
//  Satodime
//
//  Created by Lionel Delvaux on 05/11/2023.
//

import Foundation

// MARK: - Protocol
protocol PLoggerService {
    func getLogs() -> [Log]
    func addLog(level: LogLevel, msg: String, tag: String)
}

// MARK: - Service
final class LoggerService: PLoggerService {
    
    // Singleton pattern
    static let shared = LoggerService()
    var logs = [Log]()
    var lock = NSLock()
    
    private init() { }
    
    func getLogs() -> [Log] {
        return self.logs
    }
    
    func addLog(level: LogLevel, msg: String, tag: String = "") {
        let log = Log(time: Date(), level: level, msg: msg, tag: tag)
        self.lock.lock()
        self.logs.append(log)
        self.lock.unlock()
    }
    
    func warning(_ msg: String, tag: String = "") {
        #if DEBUG
        print("🟡 " + msg)
        #endif
        self.addLog(level: LogLevel.warn, msg: msg, tag: tag)
    }
    
    func error(_ msg: String, tag: String = "") {
        #if DEBUG
        print("🔴 " + msg)
        #endif
        self.addLog(level: LogLevel.error, msg: msg, tag: tag)
    }
    
    func info(_ msg: String, tag: String = "") {
        #if DEBUG
        print("🔵 " + tag + " - " + msg)
        #endif
        self.addLog(level: LogLevel.info, msg: msg, tag: tag)
    }
    
    func debug(_ msg: String, tag: String = "") {
        #if DEBUG
        print("🟢 " + msg)
        #endif
        self.addLog(level: LogLevel.debug, msg: msg, tag: tag)
    }
    
}
