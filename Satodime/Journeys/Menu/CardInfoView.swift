//
//  CardInfoView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 14/10/2023.
//

import Foundation
import SwiftUI

struct CardInfoView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: CardInfoViewModel
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 66)
                
                SatoText(text: viewModel.ownerTitle, style: .lightSubtitle)
                
                Spacer()
                    .frame(height: 14)
                
                CardInfoBox(text: viewModel.cardVaults.isOwner ? viewModel.ownerText : viewModel.notOwnerText , backgroundColor: viewModel.cardVaults.isOwner ? Constants.Colors.darkLedGreen : Constants.Colors.ledRed)
                
                Spacer()
                    .frame(height: 33)
                
                SatoText(text: viewModel.cardVersionTitle, style: .lightSubtitle)
                
                Spacer()
                    .frame(height: 14)
                
                CardInfoBox(text: viewModel.cardVaults.cardVersion, backgroundColor: Constants.Colors.darkLedGreen)
                    .padding([.leading, .trailing], 82)
                
                Spacer()
                
                Rectangle()
                    .frame(width: .infinity, height: 2)
                    .foregroundColor(Constants.Colors.separator)
                    .padding([.leading, .trailing], 31)
                
                Spacer()
                
                SatoText(text: viewModel.cardGenuineTitle, style: .lightSubtitle)
                
                Spacer()
                    .frame(height: 14)
                
                CardInfoBox(text: viewModel.cardVaults.isCardAuthentic ? viewModel.cardGenuineText : viewModel.cardNotGenuineText, backgroundColor: viewModel.cardVaults.isCardAuthentic ? Constants.Colors.darkLedGreen : Constants.Colors.ledRed) {
                    viewModel.gotoAuthenticityScreen()
                }
                    .padding([.leading, .trailing], 57)
                
                Spacer()
                    .frame(height: 21)
                
                CardInfoBox(text: viewModel.certButtonTitle, backgroundColor: Constants.Colors.blueMenuButton) {
                   viewModel.onCertButtonTapped()
                }
                    .padding([.leading, .trailing], 71)
                
                NavigationLink(destination: ShowCertificates(certificateCode: viewModel.cardVaults.cardAuthenticity!.certificateCode, certificateDic: viewModel.cardVaults.cardAuthenticity!.certificateDic), isActive: $viewModel.isCertDetailsViewActive){EmptyView()}
                
                NavigationLink(destination: AuthenticView(viewModel: AuthenticViewModel(authState: viewModel.cardVaults.isCardAuthentic ? .isAuthentic : .notAuthentic, viewStackHandler: viewModel.viewStackHandler)), isActive: $viewModel.shouldShowAuthenticityScreen){EmptyView()}
                
                Spacer()
                    .frame(height: 139)

            }.padding([.leading, .trailing], Constants.Dimensions.smallSideMargin)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: viewModel.title, style: .lightTitle)
            }
        }
    }
}

