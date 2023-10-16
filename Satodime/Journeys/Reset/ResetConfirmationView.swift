//
//  ResetConfirmationView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 13/10/2023.
//

import Foundation
import SwiftUI

struct ResetConfirmationView: View {
    // MARK: - Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandler
    @ObservedObject var viewModel: ResetConfirmationViewModel
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 95)
                
                SatoText(text: viewModel.title, style: .lightTitle)
                
                Spacer()
                    .frame(height: 20)
                
                SatoText(text: viewModel.subtitle, style: .lightTitle)
                
                Spacer()
                    .frame(height: 44)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                        .background(Color.clear)
                        .frame(height: 169)
                        .overlay(
                            Image("ic_plus_circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 38, height: 38)
                        )
                }
                
                Spacer()
                    .frame(height: 86)
                
                SatoText(text: viewModel.confirmationText, style: .graySubtitle)
                
                Spacer()
                
                SatoButton(staticWidth: 222, text: viewModel.continueButtonTitle, style: .confirm) {
                    viewModel.completeFlow()
                }
                
                Spacer()
                    .frame(height: 29)
                
            }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.viewStackHandler = viewStackHandler
        }
    }
}
