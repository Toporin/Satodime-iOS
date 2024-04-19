//
//  AlertsHandlerView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 21/02/2024.
//

import Foundation
import SwiftUI

struct AlertsHandlerView: View {
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var nftPreviewHandler: NftPreviewHandler
    
    @Binding var showNotOwnerAlert: Bool
    @Binding var showNotAuthenticAlert: Bool
    @Binding var showCardNeedsToBeScannedAlert: Bool

    var body: some View {
        Group {
            if cardState.ownershipStatus == .notOwner && showNotOwnerAlert {
                notOwnerAlert
            }
            if cardState.hasReadCard() && cardState.certificateCode != .success && showNotAuthenticAlert {
                notAuthenticAlert
            }
            if showCardNeedsToBeScannedAlert {
                cardNeedsToBeScannedAlert
            }
            if nftPreviewHandler.shouldShowNftPreview {
                nftPreviewAlert
            }
        }
    }

    private var notOwnerAlert: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showNotOwnerAlert = false
                }
            
            SatoAlertView(
                isPresented: $showNotOwnerAlert,
                alert: SatoAlert(
                    title: "ownership",
                    message: "ownershipText",
                    buttonTitle: String(localized:"moreInfo"),
                    buttonAction: {
                        if let url = URL(string: "https://satochip.io/satodime-ownership-explained/") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            )
                .padding([.leading, .trailing], 24)
        }
    }

    private var notAuthenticAlert: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showNotOwnerAlert = false
                }
            SatoAlertView(
                isPresented: $showNotAuthenticAlert,
                alert: SatoAlert(
                    title: "notAuthenticTitle",
                    message: "notAuthenticText",
                    buttonTitle: String(localized:"goToNotAuthenticScreen"),
                    buttonAction: {
                        DispatchQueue.main.async {
                            self.viewStackHandler.navigationState = .cardInfo
                        }
                    }
                )
            )
            .padding([.leading, .trailing], 24)
        }
    }

    private var cardNeedsToBeScannedAlert: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showNotOwnerAlert = false
                }
            SatoAlertView(
                isPresented: $showCardNeedsToBeScannedAlert,
                alert: SatoAlert(
                    title: "cardNeedToBeScannedTitle",
                    message: "cardNeedToBeScannedMessage",
                    buttonTitle: "",
                    buttonAction: {},
                    isMoreInfoBtnVisible: false
                )
            )
            .padding([.leading, .trailing], 24)
        }
    }
    
    private var nftPreviewAlert: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    nftPreviewHandler.shouldShowNftPreview = false
                }
            SatoAlertView(
                isPresented: $nftPreviewHandler.shouldShowNftPreview,
                alert: SatoAlert(
                    title: nftPreviewHandler.nftName ?? "NFT",
                    message: "",
                    buttonTitle: "Explorer",
                    buttonAction: {
                        if let webLink = nftPreviewHandler.nftExplorerUrl, let weblinkUrl = URL(string: webLink) {
                            UIApplication.shared.open(weblinkUrl)
                        }
                    },
                    isMoreInfoBtnVisible: true,
                    imageUrl: nftPreviewHandler.nftImageUrl
                )
            )
            .padding([.leading, .trailing], 24)
        }
    }
}

