//
//  AuthenticView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//

import Foundation
import SwiftUI

struct AuthenticView: View {
    @EnvironmentObject var viewStackHandler: ViewStackHandler
    @ObservedObject var viewModel: AuthenticViewModel

    var body: some View {
        ZStack {
            viewModel.backgroundColor
                .ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 29)
                
                Image("ic_logo_white_big")
                    .resizable()
                    .frame(width: 243, height: 87)
                
                Spacer()
                    .frame(height: 76)

                viewModel.imageForState
                    .resizable()
                    .frame(width: 154, height: 173)
                
                Spacer()
                    .frame(height: 38)

                SatoText(text: viewModel.textForState, style: .subtitle)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                self.viewModel.navigateTo(destination: .goBackHome)
            }) {
                Image("ic_flipback")
            })
        .onAppear {
            viewModel.viewStackHandler = viewStackHandler
        }
    }
}
