//
//  ContentView.swift
//  Satodime for iOS
//
//  Created by Satochip on 21/01/2023.
//  Copyright © 2023 Satochip S.R.L.
//
import SwiftUI
import CoreNFC
import SatochipSwift
import SwiftCryptoTools

struct ContentView: View {
    static let statusImageDict: [UInt8 : String] = [0x00 : "arrow.triangle.2.circlepath",
                                        0x01 : "lock",
                                        0x02 : "lock.open",]
    static let colorArray = [Color("Color_grey"), Color("Color_green"), Color(.orange)]
    
    @StateObject var reader = NfcReader()
    @State private var isSideBarOpened = false
    @State private var isActive: Bool = false
    @State private var selection: String? = nil
    @State private var selectionIndex: UInt8 = 0
    @State private var isFirstAppearance: Bool = true
    @State private var needsRefresh: Bool = true
    
    @AppStorage("needsAppOnboarding") var needsAppOnboarding: Bool = true
    var data = OnboardingDataModel.data
    
    var body: some View {
        ZStack {
            NavigationView {
                
                if needsAppOnboarding {
                    OnboardingViewPure(data: data, doneFunction: {
                        /// Update your state here
                        needsAppOnboarding = false
                        print("done onboarding")
                    })
                } else {
                    
                    VStack {
                        
                        // top image and buttons
                        HStack {
                            Button (action: {
                                reader.operationType = "ShowCertificates";
                                reader.operationIndex = 0;
                                reader.operationRequested = true;
                            }){
                                // todo: image depending on certificate status: ok, nok or n/a (no card)
                                // checkmark.seal, xmark.seal, seal
                                if (reader.certificateCode == PkiReturnCode.success){
                                    //Image("card_authentic_ok")
                                    Image(systemName: "checkmark.shield")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50)
                                        .foregroundColor(Color("Color_gold"))
                                    //.scaledToFit()
                                } else {
                                    Image(systemName: "xmark.shield")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50)
                                        .foregroundColor(.red)
                                }
                            }
                            Image("logo_horizontal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200)
                            //.scaledToFit()
                            Button (action: {
                                isSideBarOpened.toggle()
                            }){
                                Image(systemName: "line.3.horizontal.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50)
                                    .foregroundColor(Color("Color_gold"))
                                //.scaledToFit()
                            }
                        } // HStack
                        
                        if (reader.vaultArray.count == 0){
                            Spacer()
                            Text("Refresh to scan a card")
                            Spacer()
                        }
                        
                        // for each vault
                        List {
                            ForEach(reader.vaultArray, id: \.index) { item in
                                VStack {
                                    
                                    // vault #, asset & action button
                                    HStack {
                                        //Capsule()
                                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                                            .foregroundColor(ContentView.colorArray[Int(item.keyslotStatus.status)])
                                            .frame(width: 100, height: 44)
                                            .overlay(Text("Vault #\(Int64(item.index))"))
                                        //                                    Text("Vault #\(item.index)")
                                        //                                        .font(.headline)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            reader.operationType = "Action";
                                            reader.operationIndex = item.index;
                                            reader.operationRequested = true;
                                            print("Button Action for \(item.index)")}) {
                                                VStack {
                                                    Image(systemName: ContentView.statusImageDict[item.keyslotStatus.status] ?? "arrow.triangle.2.circlepath")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 30)
                                                        .foregroundColor(Color("Color_foreground"))
                                                    //Text("\(item.getStatusString())")
                                                    Text(LocalizedStringKey(item.getStatusString()))
                                                }
                                            }
                                            .buttonStyle(.borderless)
                                    } // HStack
                                    
                                    // coin image, address, balance
                                    HStack {
                                        Image(item.iconPath)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100)
                                        VStack {
                                            //Text("Adress: \(item.address)")
                                            HStack {
                                                //Text("Adress: ")
                                                Image(systemName: "scope")
                                                    .foregroundColor(Color("Color_foreground"))
                                                Text("\(item.address)")
                                                    .font(.footnote)
                                            }
                                            HStack {
                                                Image(systemName: "banknote")
                                                    .foregroundColor(Color("Color_foreground"))
                                                VStack {
                                                    Text("\(item.getBalanceString())")
                                                        .font(.footnote)
                                                }
                                            }
                                            
                                        }
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            reader.operationType = "Details";
                                            reader.operationIndex = item.index;
                                            reader.operationRequested = true;
                                            print("Button Details for \(item.index)")}) {
                                                Image(systemName: "chevron.right.circle")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 30)
                                                    .foregroundColor(Color("Color_foreground"))
                                            }
                                        //                                    .padding()
                                        //                                    .foregroundColor(Color("Color_foreground"))
                                        //                                    .background(Color.gray)
                                        //                                    .cornerRadius(.infinity)
                                            .buttonStyle(.borderless)
                                    }
                                    
                                } // VStack
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(ContentView.colorArray[Int(item.keyslotStatus.status)], lineWidth: 4)
                                )
                                
                                
                            } // foreach
                            
                        }// List
                        .listStyle(.grouped)
                        //.toolbar(.hidden, for: .navigationBar) // hide title on iOS 16 ?
                        .navigationTitle("List of vaults")
                        .navigationBarHidden(true) // hide title on iOS<16 ?
                        .onAppear {
                            // only scan when needed, i.e. on start or when a vault changes
                            //if isFirstAppearance {
                            if reader.needsRefresh {
                                Task {
                                    await reader.executeQuery()
                                    reader.needsRefresh.toggle()
                                    isFirstAppearance.toggle()
                                }
                            }
                        }
                        .refreshable {
                            Task {
                                await reader.executeQuery()
                            }
                        }
                        .background(
                            NavigationLink(destination: getDestination(operation: reader.operationType, from: reader.operationIndex), isActive: $reader.operationRequested){EmptyView()}
                        )
                    } // Vstack
                } // else onboardingDone !needsAppOnboarding
            }// navigationview
            SideMenu(isSidebarVisible: $isSideBarOpened)
        }// ZStack
        .environmentObject(reader)
    }// body
    
    func getDestination(operation: String, from index: UInt8) -> AnyView {
        print("getDestination operation: \(operation) from index: \(index)")
        if operation == "Action"{
            if index>=reader.vaultArray.count {
                print("reader.vaultArray.count: \(reader.vaultArray.count)")
                return AnyView(UnknownAction(operation: operation, index: index))
            }
            let status = reader.vaultArray[Int(index)].keyslotStatus.status
            switch status {
            case 0x00:
                return AnyView(SealSlot(index: index))
            case 0x01:
                return AnyView(UnsealSlot(index: index))
            case 0x02:
                return AnyView(ResetSlot(index: index))
            default:
                return AnyView(UnknownAction(operation: operation, index: index))
            }
        } else if operation == "Details"{// show details
            if index>=reader.vaultArray.count {
                print("reader.vaultArray.count: \(reader.vaultArray.count)")
                return AnyView(UnknownAction(operation: operation, index: index))
            }
            return AnyView(ShowDetails(item: reader.vaultArray[Int(index)], index: Int(index)))
        } else if operation == "Accept" {// show details
            return AnyView(AcceptCard())
        } else if operation == "Transfer" {// show details
            return AnyView(TransferCard())
        } else if operation == "Settings" {
            return AnyView(Settings())
        } else if operation == "CardInfo" {
            return AnyView(CardInfo())
        } else if operation == "ShowCertificates" {
            //return AnyView(ShowCertificates(certificateCode: reader.certificateCode, certificates: reader.certificates))
            return AnyView(ShowCertificates(certificateCode: reader.certificateCode, certificateDic: reader.certificateDic))
        } else if operation == "ShowLogs" {
            return AnyView(ShowLogs(logArray: reader.logArray))
        } else {
            return AnyView(UnknownAction(operation: operation, index: index))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(NfcReader())
    }
}
