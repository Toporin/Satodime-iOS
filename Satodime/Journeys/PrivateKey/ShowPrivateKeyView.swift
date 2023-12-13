//
//  ShowPrivateKeyView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 30/10/2023.
//

import Foundation
import SwiftUI

struct ShowPrivateKeyView: View {
    // MARK: - Properties
    @Environment(\.presentationMode) var presentation
//    @EnvironmentObject var viewStackHandler: ViewStackHandler
//    @ObservedObject var viewModel: ShowPrivateKeyViewModel
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    
    // MARK: - Properties
    @State var keyToDisplay: String = ""
    @State var titleMode: String = ""
    @State var subtitleMode: String = ""
    @State var slotNumber: String = ""
    @State var coinIcon: String = ""
    
    let index: Int
    var mode: ShowPrivateKeyMode
//    var keyResult: PrivateKeyResult?
//    private var vault: VaultItem

    // MARK: - Literals
    let title = "showPrivateKey"
    
    // MARK: - Helpers
    func copyToClipboard() {
        UIPasteboard.general.string = self.keyToDisplay
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        generator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.impactOccurred()
        }
    }
    
    func determineKeyToDisplay() {
//        guard let keyResult = self.keyResult else { return }
//        self.vault.privkey = keyResult.privkey
//        self.vault.entropy = keyResult.entropy
        
        guard cardState.vaultArray.count > self.index else { return }
        
        self.coinIcon = cardState.vaultArray[index].iconPath
        
        switch mode {
        case .legacy:
            self.titleMode = "privateKey"
            self.subtitleMode = "(Legacy)"
            self.keyToDisplay = cardState.vaultArray[index].getPrivateKeyString()
        case .wif:
            self.titleMode = "privateKey"
            self.subtitleMode = "(Wallet Import Format)"
            self.keyToDisplay = cardState.vaultArray[index].getWifString()
        case .entropy:
            self.titleMode = "entropyMode"
            self.subtitleMode = ""
            self.keyToDisplay = cardState.vaultArray[index].getEntropyString()
        }
    }
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    VStack {
                        Image("bg_red_gradient")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: 269)
                            .clipped()
                            .ignoresSafeArea()
                        
                        Spacer()
                    }
                    
                    VStack {
                        Spacer()
                            .frame(height: 38)
                        
                        HStack {
                            SatoText(text: "0\(index+1)", style: .slotTitle)
                            Spacer()
                        }
                        
                        Spacer()
                            .frame(height: 4)
                        HStack {
                            SealStatusView(status: .unsealed)
                            Spacer()
                            Image(coinIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                    }
                    .padding([.leading, .trailing], Constants.Dimensions.bigSideMargin)
                }
                
                Spacer()
            }
            
            ZStack {
                VStack {
                    Spacer()
                        .frame(height: 148)
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .foregroundColor(Constants.Colors.bottomSheetBackground)
                        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 0)
                        .ignoresSafeArea()
                        .edgesIgnoringSafeArea(.all)

                }
                
                VStack(alignment: .center) {
                    Spacer()
                        .frame(height: 168)
                    
                    SatoText(text: titleMode, style: .title)
                    Spacer()
                        .frame(height: 2)
                    SatoText(text: subtitleMode, style: .lightSubtitle)
                    
                    Spacer()
                        .frame(height: 38)
                    
                    SatoText(text: keyToDisplay, style: .subtitle)
                    
                    Spacer()
                        .frame(height: 38)

                    HStack(spacing: 15) {
                        SatoText(text: "copyToClipboard", style: .addressText)
                            .lineLimit(1)
                            .frame(alignment: .trailing)
                        
                        Spacer()
                            .frame(width: 2)
                        
                        Button(action: {
                            self.copyToClipboard()
                        }) {
                            Image("ic_copy_clipboard")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                        .frame(height: 16)

                    if let cgImage = QRCodeHelper().getQRfromText(text: keyToDisplay) {
                        Image(uiImage: UIImage(cgImage: cgImage))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 219, height: 219, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    
                    Spacer()
                }
                .padding([.leading, .trailing], Constants.Dimensions.bigSideMargin)
            }
        }// ZStack
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentation.wrappedValue.dismiss()
        }) {
            Image("ic_flipback")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: title, style: .lightTitle)
            }
        }
        .onAppear{
            self.determineKeyToDisplay()
        }
    } // body
}

