//
//  Settings.swift
//  Satodime for iOS
//
//  Created by Satochip on 21/01/2023.
//  Copyright © 2023 Satochip S.R.L.
//

import SwiftUI
import CryptoSwift

struct Settings: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var reader: NfcReader
    @AppStorage("needsAppOnboarding") var needsAppOnboarding: Bool = true
    @State var showLogs = false
    
    // form
    static let languages = ["English", "Français"]
    var currencies = ["EUR", "USD", "BTC", "ETH"]
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "gearshape")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .padding(20)
                    .background(Color("Color_grey"))
                    .clipShape(Circle())
                
                Text("Settings")
                    .font(.title)
                    .padding(10)
                
                Form {
                    
                    // dark mode is set globally for the device
                    //                Section() {
                    //                    Toggle("Use dark mode", isOn: $reader.darkMode)
                    //                }
                    
                    // language is set globally for the device
                    //                Section(header: Text("Select language:")) {
                    //                    Picker("Please choose a language", selection: $reader.selectedLanguage) {
                    //                        ForEach(Settings.languages, id: \.self) {
                    //                            Text($0)
                    //                        }
                    //                    }
                    //                    .pickerStyle(MenuPickerStyle())
                    //                }
                    
                    // deprecated
//                    Section(header: Text("Select currency:")) {
//                        Picker("Please choose currency:", selection: $reader.selectedCurrency) {
//                            ForEach(currencies, id: \.self) {
//                                Text($0)
//                            }
//                        }
//                        .pickerStyle(MenuPickerStyle())
//                    }
                    
                    // selectedFirstCurrency is the native currency for each vault (BTC, ETH, ...)
//                    Section(header: Text("Select main currency:")) {
//                        Picker("Please choose currency:", selection: $reader.selectedFirstCurrency) {
//                            ForEach(currencies, id: \.self) {
//                                Text($0)
//                            }
//                        }
//                        .pickerStyle(MenuPickerStyle())
//                    }
                    
                    // second currency is typically fiat
                    Section(header: Text("Select second currency:")) {
                        Picker("Please choose currency:", selection: $reader.selectedSecondCurrency) {
                            ForEach(currencies, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // dark mode is set globally for the device
                    Section() {
                        Toggle("Onboarding intro:", isOn: $needsAppOnboarding)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showLogs = true
                            print("Button show logs")
                        }) {
                            HStack{
                                Image(systemName: "scroll")
                                Text("Show app logs")
                            }
                        }
                        .padding(20)
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .cornerRadius(20)
                        .buttonStyle(.borderless)
                        
                        Spacer()
                    }
                }// Form
                
               
                
                
            }// VStack
            .background(
                NavigationLink(destination: ShowLogs(logArray: reader.logArray), isActive: $showLogs){EmptyView()}
            )
//            .navigationBarBackButtonHidden(true)
//            .navigationTitle("Settings")
        } // NavigationView
    }// body
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
