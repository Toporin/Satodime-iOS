//
//  ShowLogs.swift
//  Satodime
//
//  Created by Satochip on 23/02/2023.
//

import SwiftUI

struct ShowLogs: View {
    
    // MARK: Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    
    var loggerService: PLoggerService
    var logsArray: [Log]
    
    init() {
        self.loggerService = LoggerService.shared
        self.logsArray = loggerService.getLogs()
    }
    
    // MARK: Helpers
    func formatLog(log: Log) -> String {
        return "\(log.time.formatted(date: .numeric, time: .shortened)) \(self.formatLogLevel(level: log.level))"
    }
    
    func formatLogLevel(level: LogLevel) -> String {
        switch level{
        case .info:
            return "🔵 INFO"
        case .debug:
            return "🟢 DEBUG"
        case .warn:
            return "🟡 WARNING"
        case .error:
            return "🔴 ERROR"
        case .critical:
            return "🔴 FATAL"
        }
    }
    
    var body: some View {
        
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            VStack {
                
                // Showing all logs
                ScrollView {
                    HStack {
                        SatoText(text: "Number of entries: \(logsArray.count)", style: .graySubtitle)
                            .font(.headline)
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.white)
                            .onTapGesture(count: 1) {
                                // copy all logs to clipboard
                                var txt=""
                                for log in logsArray {
                                    txt += log.toString()
                                }
                                UIPasteboard.general.string = txt
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.prepare()
                                generator.impactOccurred()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    generator.impactOccurred()
                                }
                            }
                    }
                    Divider()
                    VStack {
                        ForEach(logsArray, id: \.self) { item in
                            SatoText(text: self.formatLog(log: item), style: SatoTextStyle.graySubtitle)
                            if item.tag != "" {
                                SatoText(text: "\(item.tag)", style:SatoTextStyle.graySubtitle)
                            }
                            SatoText(text: "\(item.msg)", style: SatoTextStyle.graySubtitle, alignment: .leading)
                            Divider()
                        }
                    }
                }// ScrollView
                
            }// VStack
            .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
        }//ZStack
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.viewStackHandler.navigationState = .goBackHome
        }) {
            Image("ic_flipback")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: "Logs", style: .lightTitle)
            }
        }
    }// body
}
