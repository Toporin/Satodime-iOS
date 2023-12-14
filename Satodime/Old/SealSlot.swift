////
////  SealSlot.swift
////  Satodime for iOS
////
////  Created by Satochip on 21/01/2023.
////  Copyright © 2023 Satochip S.R.L.
////
//
//import SwiftUI
//import CryptoSwift
//import SwiftCryptoTools
//
//struct SealSlot: View {
//    let index: UInt8
//    
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    @EnvironmentObject var reader: NfcReader
//    @ObservedObject private var contractsAutocompleteObject = ContractsAutocompleteObject()
//    
//    // form
//    static var blockchains = ["BTC", "ETH", "LTC", "BCH", "XCP", "BSC"]
////    static var assetTypes = ["Coin", "Token", "NFT"]
////    static var supportToken = ["ETH", "XCP", "BSC"]
//    @State private var selectedBlockchain = "BTC"
//    @State private var selectedAsset = "Coin"
//    @State private var useTestnet = false
//    @State private var contract = ""
//    @State private var tokenid = ""
//    @State private var random = ""
//    
//    // display
//    @State private var expertMode = false
////    @State private var isContractError = true // by default
////    @State private var contractErrorMsg = ""
//    @State private var contractBytes = [UInt8]()
////    @State private var isTokenidError = true // by default
////    @State private var tokenidErrorMsg = ""
//    @State private var tokenidBytes = [UInt8]()
//    @State private var entropyBytes = [UInt8](repeating: 0, count: 32)
//    
//    var body: some View {
//        NavigationView {
//            //ScrollView {
//                //VStack {
//                    
//                    Form {
//                        Group {
//                            HStack {
//                                Spacer()
//                                Image(systemName: "lock")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 100)
//                                    .padding(30)
//                                    .foregroundColor(.white)
//                                    .background(Color("Color_grey"))
//                                    .clipShape(Circle())
//                                Spacer()
//                            }
//                            HStack {
//                                Spacer()
//                                Text("Seal vault slot #\(Int64(index))?")
//                                    .font(.title)
//                                    .padding(10)
//                                Spacer()
//                            }
//                            Text("_seal_msg")
//                                .font(.headline)
//                                .padding(10)
//                        }
//                        
//                        Section() {
//                            Toggle("Use expert mode", isOn: $expertMode)
//                        }
//
//                        Section(header: Text("Select blockchain:")) {
//                            Picker("Choose a blockchain", selection: $selectedBlockchain) {
//                                ForEach(SealSlot.blockchains, id: \.self) {
//                                    Text($0)
//                                }
//                            }
//                            .pickerStyle(MenuPickerStyle())
//                            
//                            if expertMode {
//                                Toggle("Use testnet", isOn: $useTestnet)
//                            }
//                        }
//                        
////                        if SealSlot.supportToken.contains(selectedBlockchain) {
////                            Section(header: Text("Select asset type:")) {
////                                Picker("Choose an asset", selection: $selectedAsset) {
////                                    ForEach(SealSlot.assetTypes, id: \.self) {
////                                        Text($0)
////                                    }
////                                }
////                                .pickerStyle(MenuPickerStyle())
////                            }
////                        } else {
////                            //selectedAsset = "Coin"
////                        }
//                        
////                        if (SealSlot.supportToken.contains(selectedBlockchain) && ["Token", "NFT"].contains(selectedAsset)){
////                            Section(header: Text("Enter contract adress:")){
////                                TextField("Enter your contract adress:", text: $contract)
////                                    //.focused($isFocused) // <-- add here
////                                    .onChange(of: contract) { [contract] newContract in
////                                        do {
////                                            //print("newContract: \(newContract)")
////                                            switch selectedBlockchain {
////                                            case "ETH":
////                                                contractBytes = try Ethereum.contractStringToBytes(contractString: newContract)
////                                            case "XCP":
////                                                contractBytes = try Counterparty.contractStringToBytes(contractString: newContract)
////                                            default:
////                                                contractBytes = [UInt8]()
////                                            }
////                                            isContractError = false
////                                            contractErrorMsg = "OK!"
////                                        } catch {
////                                            isContractError = true
////                                            contractErrorMsg = "Wrong contract format: \(error)"
////                                            print("Wrong contract format: \(error)")
////                                        }
////
////                                        // autocomplete
////                                        contractsAutocompleteObject.autocomplete(newContract, blockchain: selectedBlockchain, asset: selectedAsset)
////                                    }
////                                List(contractsAutocompleteObject.suggestions, id: \.self) { suggestion in
////                                    ZStack {
////                                        Text(suggestion.label)
////                                    }
////                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
////                                    .onTapGesture {
////                                        //isFocused = false // <-- add here
////                                        contract = suggestion.contract
////                                        isContractError = true
////                                        contractErrorMsg = "OK!"
////                                    }
////                                }
////                                if isContractError {
////                                    HStack {
////                                        Image(systemName: "xmark.circle.fill")
////                                            .foregroundColor(.red)
////                                        Text("\(contractErrorMsg)")
////                                            .foregroundColor(.red)
////                                    }
////                                } else {
////                                    Image(systemName: "checkmark.circle.fill")
////                                        .foregroundColor(.green)
////                                }
////                            }
////                        }
//                        
////                        if (SealSlot.supportToken.contains(selectedBlockchain) && ["NFT"].contains(selectedAsset)){
////                            Section(header: Text("Enter tokenid:")){
////                                TextField("Enter your tokenid:", text: $tokenid)
////                                    .onChange(of: tokenid) { [tokenid] newTokenid in
////                                        do {
////                                            print("newTokenid: \(newTokenid)")
////                                            switch selectedBlockchain {
////                                            case "ETH":
////                                                tokenidBytes = try Ethereum.tokenidStringToBytes(tokenidString: newTokenid)
////                                            case "XCP":
////                                                tokenidBytes = try Counterparty.tokenidStringToBytes(tokenidString: newTokenid)
////                                            default:
////                                                tokenidBytes = [UInt8]()
////                                            }
////                                            isTokenidError = false
////                                            tokenidErrorMsg = "OK!"
////                                        } catch {
////                                            isTokenidError = true
////                                            tokenidErrorMsg = "Wrong tokenid format: \(error)"
////                                            print("Wrong tokenid format: \(error)")
////                                        }
////                                    }
////                                if isTokenidError {
////                                    HStack {
////                                        Image(systemName: "xmark.circle.fill")
////                                            .foregroundColor(.red)
////                                        Text("\(tokenidErrorMsg)")
////                                            .foregroundColor(.red)
////                                    }
////                                } else {
////                                    Image(systemName: "checkmark.circle.fill")
////                                        .foregroundColor(.green)
////                                }
////                            }
////                        }
//                        
//                        if expertMode {
//                            Section(header: Text("Entropy")){
//                                TextField("Enter random data:", text: $random)
//                                    .onChange(of: random) { [random] newRandom in
//                                        print("newRandom: \(newRandom)")
//                                        entropyBytes = self.extractEntropy(randomString:newRandom)
//                                    }
//                                Text("Extracted entropy: \(entropyBytes.bytesToHex)")
//                            }
//                        }
//
//                        HStack {
//                            Spacer()
//                            Button(role: .cancel, action: {
//                                self.presentationMode.wrappedValue.dismiss()
//                            }){
//                                Text("Cancel")
//                                    .foregroundColor(.white)
//                                    .font(.headline)
//                                    .padding(20)
//                                    .background(Color("Color_grey_light"))
//                                    .cornerRadius(20)
//                            }
//                            Button(role: .destructive, action:{
//                                // todo: check for error!
//                                if (true){
//                                    print("Seal operation requested!")
//                                    let actionParams = ActionParams(index: index, action: "seal", coinString: selectedBlockchain, assetString: selectedAsset, useTestnet: useTestnet, contractBytes: contractBytes, tokenidBytes: tokenidBytes, entropyBytes: entropyBytes)
//                                    reader.scanForAction(actionParams: actionParams)
//                                    self.presentationMode.wrappedValue.dismiss()
//                                } else {
//                                    // print error
//                                }
//                            }){
//                                Text("Seal")
//                                    .foregroundColor(.white)
//                                    .font(.headline)
//                                    .padding(20)
//                                    .background(Color("Color_grey"))
//                                    .cornerRadius(20)
//                            }
//                            Spacer()
//                        } // HStack buttons
//                        .buttonStyle(BorderlessButtonStyle()) //bug: https://www.hackingwithswift.com/forums/swiftui/buttons-in-a-form-section/6175
//                    
//                    } // Form
//                //} // VStack
//                //            .navigationBarBackButtonHidden(true)
//                //            .navigationTitle("Seal vault slot #\(index)")
//            //}// scrollview
//        } // NavigationView
//    }// body
//    
//    func extractEntropy(randomString: String) -> [UInt8] {
//        var randomBytes = Array(randomString.utf8)
//        if (randomBytes.count>32){
//            randomBytes = Digest.sha256(randomBytes)
//        } else if randomBytes.count<32 {
//            randomBytes = randomBytes + [UInt8](repeating: 0, count: 32-randomBytes.count)
//        }
//        return randomBytes
//    }
//}
//
//struct SealSlot_Previews: PreviewProvider {
//    static var previews: some View {
//        SealSlot(index: 0)
//    }
//}
