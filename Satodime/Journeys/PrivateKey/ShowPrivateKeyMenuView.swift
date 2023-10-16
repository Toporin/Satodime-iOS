//
//  ShowPrivateKeyMenuView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import SwiftUI

struct ShowPrivateKeyMenuView: View {
    // MARK: - Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandler
    @ObservedObject var viewModel: ShowPrivateKeyMenuViewModel
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 37)
                
                VaultCard(viewModel: viewModel.vaultCardViewModel, indexPosition: viewModel.indexPosition, useFullWidth: true)
                    .padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
                
                Spacer()
                    .frame(height: 27)
                
                List {
                    ForEach(viewModel.keyDisplayOptions, id: \.self) { mode in
                        SatoSelectionButton(mode: mode)
                            .onTapGesture {
                                viewModel.showKey(mode: mode)
                            }.listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
                .listRowSpacing(0)
                .background(Color.clear)
                .sheet(isPresented: $viewModel.isBottomSheetPresented) {
                    if let keyResult = viewModel.keyResult {
                        KeyBottomSheetView(viewModel: KeyBottomSheetViewModel(mode: viewModel.selectedMode, keyResult: keyResult, vault: viewModel.vaultCardViewModel.vaultItem))
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.viewModel.navigateTo(destination: .goBackHome)
        }) {
            Image("ic_flipback")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: viewModel.title, style: .lightTitle)
            }
        }
        .onAppear {
            viewModel.viewStackHandler = viewStackHandler
        }
    }
}

struct KeyBottomSheetView: View {
    @ObservedObject var viewModel: KeyBottomSheetViewModel

    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 20) {
                Spacer()
                    .frame(height: 31)
                
                SatoText(text: viewModel.mode.rawValue, style: .title)
                
                Spacer()
                    .frame(height: 47)
                
                SatoText(text: viewModel.keyToDisplay, style: .subtitle)
                
                Spacer()
                    .frame(height: 53)

                HStack(spacing: 15) {
                    SatoText(text: "Copy to clipboard", style: .addressText)
                        .lineLimit(1)
                        .frame(alignment: .trailing)
                    
                    Spacer()
                        .frame(width: 13)
                    
                    Button(action: {
                        viewModel.copyToClipboard()
                    }) {
                        Image("ic_copy_clipboard")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                    .frame(height: 20)

                if let cgImage = QRCodeHelper().getQRfromText(text: viewModel.keyToDisplay) {
                    Image(uiImage: UIImage(cgImage: cgImage))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 219, height: 219, alignment: .center)
                }
                
                Spacer()
            }
        }
    }
}


class KeyBottomSheetViewModel: ObservableObject {
    @Published var keyToDisplay: String = ""
    var mode: ShowPrivateKeyMode
    var keyResult: PrivateKeyResult
    private var vault: VaultItem

    init(mode: ShowPrivateKeyMode, keyResult: PrivateKeyResult, vault: VaultItem) {
        self.mode = mode
        self.keyResult = keyResult
        self.vault = vault
        determineKeyToDisplay()
    }

    func determineKeyToDisplay() {
        switch mode {
        case .legacy:
            self.keyToDisplay = vault.getPrivateKeyString()
        case .wif:
            self.keyToDisplay = vault.getWifString()
        case .entropy:
            self.keyToDisplay = vault.getEntropyString()
        }
    }

    func copyToClipboard() {
        UIPasteboard.general.string = self.keyToDisplay
    }
}

