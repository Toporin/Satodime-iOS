//
//  ShowLogs.swift
//  Satodime
//
//  Created by Satochip on 23/02/2023.
//

import SwiftUI

struct ShowLogs: View {
    var loggerService: PLoggerService
    var logArray: [String]
    var logsArray: [Log]
    
    init() {
        self.loggerService = LoggerService()
        self.logArray = loggerService.getLog() // TODO: remove
        self.logsArray = loggerService.getLogs()
    }
    
    var body: some View {
        
        ScrollView {
            Text("Logs")
                .font(.title)
            HStack {
                Text("Number of entries: \(logsArray.count)")
                    .font(.headline)
                Image(systemName: "doc.on.doc")
                    .onTapGesture(count: 1) {
                        var txt=""
                        for log in logsArray {
                            txt += log.toString()
                        }
                        UIPasteboard.general.string = txt
                    }
            }
            Divider()
            VStack {
//                ForEach(logArray, id: \.self) { item in
//                    Text("\(item)")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    Divider()
//                }
                ForEach(logsArray, id: \.self) { item in
                    Text("\(item.time)")
                    Text("\(item.level.rawValue)")
                    if item.tag != "" {
                        Text("\(item.tag)")
                    }
                    Text("\(item.msg)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                }
            }
        }
    }
}
