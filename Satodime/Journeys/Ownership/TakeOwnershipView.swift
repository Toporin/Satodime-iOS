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
                SatoButton(text: "Accept", style: .confirm, horizontalPadding: 60) {
                    
                }
                Spacer()
                    .frame(height: 20)
                SatoButton(text: "Cancel", style: .inform, horizontalPadding: 30) {
                    
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
    }
}
