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
    @EnvironmentObject var viewStackHandler: ViewStackHandler
    @ObservedObject var viewModel: ShowPrivateKeyViewModel
    
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
                            SatoText(text: viewModel.slotNumber, style: .slotTitle)
                            Spacer()
                        }
                        
                        Spacer()
                            .frame(height: 4)
                        HStack {
                            SealStatusView(status: .unsealed)
                            Spacer()
                            Image(viewModel.coinIcon)
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
                    
                    SatoText(text: viewModel.titleMode, style: .title)
                    Spacer()
                        .frame(height: 2)
                    SatoText(text: viewModel.subtitleMode, style: .lightSubtitle)
                    
                    Spacer()
                        .frame(height: 38)
                    
                    SatoText(text: viewModel.keyToDisplay, style: .subtitle)
                    
                    Spacer()
                        .frame(height: 38)

                    HStack(spacing: 15) {
                        SatoText(text: "copyToClipboard", style: .addressText)
                            .lineLimit(1)
                            .frame(alignment: .trailing)
                        
                        Spacer()
                            .frame(width: 2)
                        
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
                        .frame(height: 16)

                    if let cgImage = QRCodeHelper().getQRfromText(text: viewModel.keyToDisplay) {
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: viewModel.title, style: .viewTitle)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentation.wrappedValue.dismiss()
        }) {
            Image("ic_flipback")
        })
    }
}

