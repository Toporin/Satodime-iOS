//
//  AuthenticView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//

import Foundation
import SwiftUI
import SatochipSwift

struct AuthenticView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    
    @State var shouldShowDeviceInfo = false
    @State var shouldShowSubcaInfo = false
    
    // var fromView: NavigationState?
    @Binding var shouldShowAuthenticityScreen: Bool
    var shouldBreakNavigationLink: Bool
    
    // MARK: Helpers
    func getReasonFromPkiReturnCode(pkiReturnCode: PkiReturnCode) -> String {
        switch(pkiReturnCode) {
        case PkiReturnCode.FailedToVerifyDeviceCertificate:
            return "_reason_wrong_sig"
        case PkiReturnCode.FailedChallengeResponse:
            return "_reason_wrong_challenge"
        case PkiReturnCode.unknown:
            return "_reason_unknown"
        default:
            return "Reason: \(pkiReturnCode)"
        }
    }
    
    func getCertificateInfo(cardState: CardState) -> String {
        var txt=""
        if (cardState.certificateCode == .success){
            txt += "Device authenticated successfully!"
            txt += "\n\n"
        } else {
            txt += "Failed to authenticate device!"
            txt += "\n\n"
            txt += getReasonFromPkiReturnCode(pkiReturnCode: cardState.certificateCode)
            txt += "\n\n"
        }
        txt += "Device info:"
        txt += "\n\n"
        txt += "Pubkey: \(cardState.certificateDic["devicePubkey"] ?? "(none)")"
        txt += "\n\n"
        txt += "Signature: \(cardState.certificateDic["deviceSig"] ?? "(none)")"
        txt += "\n\n"
        txt += "PEM: \(cardState.certificateDic["devicePem"] ?? "(none)")"
        txt += "\n\n"
        txt += "Subca info:"
        txt += "\n\n"
        txt += "Pubkey: \(cardState.certificateDic["subcaPubkey"] ?? "(none)")"
        txt += "\n\n"
        txt += "PEM: \(cardState.certificateDic["subcaPem"] ?? "(none)")"
        txt += "\n\n"
        return txt
    }
    
    // MARK: Body
    var body: some View {
        ZStack {
            
            if cardState.certificateCode == .success {
                Constants.Colors.viewBackground
                    .ignoresSafeArea()
            } else if cardState.certificateCode == .unknown { // TODO: something particuliar?
                Constants.Colors.errorViewBackground
                    .ignoresSafeArea()
            } else {
                Constants.Colors.errorViewBackground
                    .ignoresSafeArea()
            }
            ScrollView{
                VStack {
                    Spacer()
                        .frame(height: 29)
                    
                    Image("ic_logo_white_big")
                        .resizable()
                        .frame(width: 243, height: 87)
                    
                    Spacer()
                        .frame(height: 76)
                    
                    if cardState.certificateCode == .success {
                        Image("il_authentic")
                            .resizable()
                            .frame(width: 150, height: 150)
                        Spacer()
                            .frame(height: 38)
                        SatoText(text: "authenticationSuccess", style: .subtitle)
                    } else if cardState.certificateCode == .unknown { // TODO: something particuliar?
                        Image("il_not_authentic")
                            .resizable()
                            .frame(width: 150, height: 150)
                        Spacer()
                            .frame(height: 38)
                        SatoText(text: "authenticationFailed", style: .subtitle)
                    } else {
                        Image("il_not_authentic")
                            .resizable()
                            .frame(width: 150, height: 150)
                        Spacer()
                            .frame(height: 38)
                        SatoText(text: "authenticationFailed", style: .subtitle)
                    }
                    
                    Spacer()
                        .frame(height: 33)
                    
//                    // CERTIFICATE DETAILS
//                    HStack {
//                        Text("deviceInfo")
//                            .foregroundColor(.white)
//                            .font(.title2)
//                        Image(systemName: "doc.on.doc")
//                            .foregroundColor(.white)
//                            .onTapGesture(count: 1) {
//                                UIPasteboard.general.string = getCertificateInfo(cardState: cardState)
//                                let generator = UIImpactFeedbackGenerator(style: .medium)
//                                generator.prepare()
//                                generator.impactOccurred()
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                    generator.impactOccurred()
//                                }
//                            }
//                    }
                    
                    // DEVICE CERT
                    CardInfoBox(
                        text: self.shouldShowDeviceInfo ? "hideDeviceCert" : "showDeviceCert",
                        backgroundColor: cardState.certificateCode == .success ? Constants.Colors.darkLedGreen : Constants.Colors.ledRed)
                    {
                        self.shouldShowDeviceInfo.toggle()
                    }
                        .padding([.leading, .trailing], 57)
                    
                    if self.shouldShowDeviceInfo {
                        VStack {
                            
                            HStack {
                                Text("copyToClipboard")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .padding(15)
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.white)
                                    .onTapGesture(count: 1) {
                                        UIPasteboard.general.string = getCertificateInfo(cardState: cardState)
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.prepare()
                                        generator.impactOccurred()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            generator.impactOccurred()
                                        }
                                    }
                            }
                            
                            Text("Pubkey: \n\(cardState.certificateDic["devicePubkey"] ?? "(none)")")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .padding(15)

                            Text("PEM: \n\(cardState.certificateDic["devicePem"] ?? "(none)")")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .padding(15)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(cardState.certificateCode == .success ? Constants.Colors.darkLedGreen : Constants.Colors.ledRed, lineWidth: 4)
                                .padding(15)
                        )
                    }
                    
                    Spacer()
                        .frame(height: 33)
                    
                    CardInfoBox(
                        text: self.shouldShowSubcaInfo ? "hideSubcaCert" : "showSubcaCert",
                        backgroundColor: cardState.certificateCode == .success ? Constants.Colors.darkLedGreen : Constants.Colors.ledRed)
                    {
                        self.shouldShowSubcaInfo.toggle()
                    }
                        .padding([.leading, .trailing], 57)
                    
                    if self.shouldShowSubcaInfo {
                        VStack {
                            HStack {
                                Text("copyToClipboard")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .padding(15)
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.white)
                                    .onTapGesture(count: 1) {
                                        UIPasteboard.general.string = getCertificateInfo(cardState: cardState)
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.prepare()
                                        generator.impactOccurred()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            generator.impactOccurred()
                                        }
                                    }
                            }
                            
                            Text("Pubkey: \(cardState.certificateDic["subcaPubkey"] ?? "(none)")")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .padding(15)
                            
                            Text("PEM: \(cardState.certificateDic["subcaPem"] ?? "(none)")")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .padding(15)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(cardState.certificateCode == .success ? Constants.Colors.darkLedGreen : Constants.Colors.ledRed, lineWidth: 4)
                                .padding(15)
                        )
                    }
                    
                } // VStack
            }// ScrollView
        } // ZStack
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: 
            Button(action: {
                DispatchQueue.main.async {
                    if self.shouldBreakNavigationLink {
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        viewStackHandler.navigationState = .goBackHome
                    }
                }
            })
            {
                Image("ic_flipback")
            })
    } // body
}
