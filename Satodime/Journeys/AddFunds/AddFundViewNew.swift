//
//  AddFundsView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 02/11/2023.
//

import Foundation
import SwiftUI

struct AddFundsViewNew: View {
    // MARK: - Properties
    @Environment(\.presentationMode) var presentation
    //@EnvironmentObject var viewStackHandler: ViewStackHandler
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    //@ObservedObject var viewModel: AddFundsViewModel
    var index: Int
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    VStack {
                        Image(self.getHeaderImageName())
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
                            SealStatusView(status: cardState.vaultArray[index].getStatus())
                            Spacer()
                            Image(cardState.vaultArray[index].iconPath)
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
                    
                    SatoText(text: "depositAddress", style: .title)
                    Spacer()
                        .frame(height: 22)
                    SatoText(text: self.getAddress(), style: .subtitle)

                    Spacer()
                        .frame(height: 30)

                    HStack(spacing: 15) {
                        SatoText(text: "Copy to clipboard", style: .addressText)
                            .lineLimit(1)
                            .frame(alignment: .trailing)
                        
                        Spacer()
                            .frame(width: 2)
                        
                        Button(action: {
                            self.copyAddressToClipboard()
                        }) {
                            Image("ic_copy_clipboard")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                        .frame(height: 30)

                    if let cgImage = QRCodeHelper().getQRfromText(text: self.getAddress()) {
                        Image(uiImage: UIImage(cgImage: cgImage))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 219, height: 219, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    
                    Spacer()
                        .frame(height: 30)
                    SatoText(text: "youOrAnybodyCanDepositFunds", style: .lightSubtitle)
                    
                    Spacer()
                }
                .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin) //Constants.Dimensions.bigSideMargin //TODO: reduce margin so that address fits in one ligne?
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: "addFunds", style: .lightTitle)
            }
        }
//        .onAppear {// TODO: remove
//            //viewModel.viewStackHandler = viewStackHandler
//        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            //self.viewModel.navigateTo(destination: .goBackHome)
            self.viewStackHandler.navigationState = .goBackHome
        }) {
            Image("ic_flipback")
        })
    } // body
    
    // helpers
    func getHeaderImageName() -> String {
        guard index < cardState.vaultArray.count else {return "bg_red_gradient"}
        return cardState.vaultArray[index].getStatus() == .sealed ? "bg_header_addfunds" : "bg_red_gradient"
    }
    
    func getAddress() -> String {
        guard index < cardState.vaultArray.count else {return ""}
        return cardState.vaultArray[index].address
    }
    
    func copyAddressToClipboard() {
        UIPasteboard.general.string = self.getAddress()
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        generator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.impactOccurred()
        }
    }
    
}


