//
//  LoggerService.swift
//  Satodime
//
//  Created by Lionel Delvaux on 05/11/2023.
//

import Foundation

// TODO: merge LoggerService & ConsoleLogger

// MARK: - Protocol
protocol PLoggerService {
    func getLog() -> [String]
    func getLogs() -> [Log]
    func log(entry: String)
}



// MARK: - Service
final class LoggerService: PLoggerService, ObservableObject {
//    var consoleLogger = ConsoleLogger()
    
    @Published var logs = [Log]()
    
    //TODO: remove
    func getLog() -> [String] {
        let log = UserDefaults.standard.object(forKey: "log") as? String ?? ""
        return log.components(separatedBy: "\n")
    }
    // TODO: remove
    func log(entry: String) {
        var currentLog: String = UserDefaults.standard.object(forKey: "log") as? String ?? ""
        currentLog.append("\(entry) \n")
        UserDefaults.standard.set(currentLog, forKey: "log")
    }
    
    func getLogs() -> [Log] {
        return self.logs
    }
    
//    func getLogs() -> [Log] {
//        var logs = [Log]()
//        let datalogs = UserDefaults.standard.object(forKey: "logs") as? [Data] ?? [Data]()
//        for datalog in datalogs {
//            if let decodedLog = try? JSONDecoder().decode(Log.self, from: datalog) {
//                //print(decodedLog)
//                logs.append(decodedLog)
//            }
//        }
//        return logs
//    }
    
    // TODO: keep only last xxx logs...
    // TODO: improve storage?
    // => do not store logs in user default, only store as a temporary object in app?
    
    func addLog(level: LogLevel, msg: String, tag: String = "") {
        let log = Log(time: Date(), level: level, msg: msg, tag: tag)
        self.logs.append(log)
    }
    
//    func addLog(level: LogLevel, msg: String, tag: String = "") {
//        
//        let log = Log(time: Date(), level: level, msg: msg, tag: tag)
//        
//        if let encoded = try? JSONEncoder().encode(log) {
//            //print("Log encoded: \(encoded)")
//            var currentLog: [Data] = UserDefaults.standard.object(forKey: "logs") as? [Data] ?? [Data]()
//            currentLog.append(encoded)
//            UserDefaults.standard.set(currentLog, forKey: "logs")
//        }
//    }
    
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
    
    // alias
    func log(_ msg: String, tag: String = ""){
        self.debug(msg, tag: tag)
    }
    
}
