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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var cardState = CardState()
    @StateObject var viewStackHandlerNew = ViewStackHandlerNew()
    @StateObject var nftPreviewHandler = NftPreviewHandler()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(cardState)
                .environmentObject(viewStackHandlerNew)
                .environmentObject(nftPreviewHandler)
        }
    }
}
