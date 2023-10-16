//
//  TakeOwnershipView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 07/10/2023.
//

import Foundation
import SwiftUI

struct TakeOwnershipView: View {
    // MARK: - Properties
    @EnvironmentObject var viewStackHandler: ViewStackHandler
    @ObservedObject var viewModel: TakeOwnershipViewModel
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 37)
                Image("il-onboard-2")
                    .resizable()
                    .scaledToFit()
                Spacer()
                    .frame(height: 37)
                SatoText(text: viewModel.subtitle, style: .subtitle)
                Spacer()
                SatoButton(staticWidth: 196, text: "Accept", style: .confirm, horizontalPadding: 60) {
                    viewModel.acceptCard()
                }
                Spacer()
                    .frame(height: 20)
                SatoButton(staticWidth: 222, text: "Cancel", style: .inform, horizontalPadding: 30) {
                    viewModel.cancel()
                }
                Spacer()
                    .frame(height: 49)
            
            }.padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: viewModel.title, style: .viewTitle)
            }
        }
        .onAppear {
            viewModel.viewStackHandler = viewStackHandler
        }
    }
}
