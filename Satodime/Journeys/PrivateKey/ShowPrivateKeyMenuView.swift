//
//  ShowPrivateKeyMenuView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import SwiftUI

enum ShowPrivateKeyMode: String, Hashable {
    case legacy = "showPrivateKeyLegacy"
    case wif = "showPrivateKeyWIF"
    case entropy = "showEntropy"
}

struct ShowPrivateKeyMenuView: View {
    // MARK: - Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    @State var showNotOwnerAlert: Bool = false
        
    @State var selectedMode: ShowPrivateKeyMode = .legacy //TODO: need to be @State?
    @State var isKeyViewPresented = false
    
    let index: Int
    
    // MARK: - Literals
    let title = "showPrivateKey"
    let keyDisplayOptions: [ShowPrivateKeyMode] = [.legacy, .wif, .entropy]
    let notOwnerAlert = SatoAlert(
        title: "ownership",
        message: "ownershipText",
        buttonTitle: String(localized:"moreInfo"),
        buttonAction: {
            guard let url = URL(string: "https://satochip.io/satodime-ownership-explained/") else {
                print("Invalid URL")
                return
            }
            UIApplication.shared.open(url)
        }
    )
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 37)
                
                VaultCardNew(index: UInt8(index), action: {}, useFullWidth: true)
                    .padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
                
                Spacer()
                    .frame(height: 27)
                
                List {
                    ForEach(keyDisplayOptions, id: \.self) { mode in
                        SatoSelectionButton(mode: mode)
                            .onTapGesture {
                                
                                self.selectedMode = mode
                                // if the private key is not already available, scan the card to fetch it
                                if (cardState.vaultArray[index].privkey == nil) {
                                    
                                    if cardState.ownershipStatus == .owner {
                                        cardState.getPrivateKeyNew(
                                            cardAuthentikeyHex: cardState.authentikeyHex,
                                            index: index,
                                            onSuccess: {privkeyInfo in
                                                DispatchQueue.main.async {
                                                    self.cardState.vaultArray[index].privkey = privkeyInfo.privkey
                                                    self.cardState.vaultArray[index].entropy = privkeyInfo.entropy
                                                    self.selectedMode = mode
                                                    //self.isKeyViewPresented = true //TODO: view is only shown temporary?
                                                }
                                            },
                                            onFail: {
                                                print("error privkeyResult: failed to recover privkey (are you owner??")
                                            }
                                        )
                                    } else {
                                        self.showNotOwnerAlert = true
                                    }
                                } else {
                                    self.isKeyViewPresented = true
                                }
                                
                            }.listRowBackground(Color.clear)
                    }
                    
                    ButtonBox(text: String(localized: "howDoiExportPrivateKey"), iconName: "ic_link") {
                        if let url = URL(string: "https://satochip.io/satodime-how-to-export-private-key/") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                .listRowSpacing(0)
                .background(Color.clear)
                
                NavigationLink(destination: ShowPrivateKeyView(index: index, mode: selectedMode), isActive: $isKeyViewPresented) {
                    EmptyView()
                }
            }
        } //ZStack
        .overlay(
            Group {
                // Alert if user is not owner
                if showNotOwnerAlert {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showNotOwnerAlert = false
                            }
                        
                        SatoAlertView(isPresented: $showNotOwnerAlert, alert: notOwnerAlert)
                            .padding([.leading, .trailing], 24)
                    }
                }
            }
        )// overlay
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.viewStackHandler.navigationState = .goBackHome
        }) {
            Image("ic_flipback")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: title, style: .lightTitle)
            }
        }
    }//body
}

// TODO: remove?
//struct KeyBottomSheetView: View {
//    @ObservedObject var viewModel: KeyBottomSheetViewModel
//
//    var body: some View {
//        ZStack {
//            Constants.Colors.viewBackground
//                .ignoresSafeArea()
//            
//            VStack(alignment: .center, spacing: 20) {
//                Spacer()
//                    .frame(height: 31)
//                
//                SatoText(text: viewModel.mode.rawValue, style: .title)
//                
//                Spacer()
//                    .frame(height: 47)
//                
//                SatoText(text: viewModel.keyToDisplay, style: .subtitle)
//                
//                Spacer()
//                    .frame(height: 53)
//
//                HStack(spacing: 15) {
//                    SatoText(text: "copyToClipboard", style: .addressText)
//                        .lineLimit(1)
//                        .frame(alignment: .trailing)
//                    
//                    Spacer()
//                        .frame(width: 13)
//                    
//                    Button(action: {
//                        viewModel.copyToClipboard()
//                    }) {
//                        Image("ic_copy_clipboard")
//                            .resizable()
//                            .frame(width: 25, height: 25)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//                
//                Spacer()
//                    .frame(height: 20)
//
//                if let cgImage = QRCodeHelper().getQRfromText(text: viewModel.keyToDisplay) {
//                    Image(uiImage: UIImage(cgImage: cgImage))
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 219, height: 219, alignment: .center)
//                }
//                
//                Spacer()
//            }
//        }
//    }
//}


//class KeyBottomSheetViewModel: ObservableObject {
//    @Published var keyToDisplay: String = ""
//    var mode: ShowPrivateKeyMode
//    var keyResult: PrivateKeyResult
//    private var vault: VaultItem
//
//    init(mode: ShowPrivateKeyMode, keyResult: PrivateKeyResult, vault: VaultItem) {
//        self.mode = mode
//        self.keyResult = keyResult
//        self.vault = vault
//        determineKeyToDisplay()
//    }
//
//    func determineKeyToDisplay() {
//        switch mode {
//        case .legacy:
//            self.keyToDisplay = vault.getPrivateKeyString()
//        case .wif:
//            self.keyToDisplay = vault.getWifString()
//        case .entropy:
//            self.keyToDisplay = vault.getEntropyString()
//        }
//    }
//
//    func copyToClipboard() {
//        UIPasteboard.general.string = self.keyToDisplay
//        let generator = UIImpactFeedbackGenerator(style: .medium)
//        generator.prepare()
//        generator.impactOccurred()
//        generator.impactOccurred()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            generator.impactOccurred()
//        }
//    }
//}

