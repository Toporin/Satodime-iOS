//
//  SatodimeApp.swift
//  Satodime for iOS
//
//  Created by Satochip on 21/01/2023.
//  Copyright © 2023 Satochip S.R.L.
//
import SwiftUI

@main
struct SatodimeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    //@StateObject var logs = LoggerService()
    @StateObject var cardState = CardState()
    @StateObject var viewStackHandlerNew = ViewStackHandlerNew()
    
    var body: some Scene {
        WindowGroup {
            // ContentView()
            HomeView(viewModel: HomeViewModel(cardService: CardService(), coinService: CoinService()))
                //.environmentObject(logs)
                .environmentObject(cardState)
                .environmentObject(viewStackHandlerNew)
        }
    }
}
