//
//  ShowCertificates.swift
//  Satodime for iOS
//
//  Created by Satochip on 09/02/2023.
//  Copyright © 2023 Satochip S.R.L.
//

import SwiftUI
import SatochipSwift

struct ShowCertificates: View {
    @EnvironmentObject var infoToastMessageHandler: InfoToastMessageHandler
    
    var certificateCode: PkiReturnCode
    var certificateDic: [String:String]
    
    init(certificateCode: PkiReturnCode, certificateDic: [String:String]) {
        self.certificateCode = certificateCode
        self.certificateDic = certificateDic

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
        ScrollView {
                VStack {
                    if (certificateCode == PkiReturnCode.success) {
                        HStack {
                            Image(systemName: "checkmark.shield")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40)
                                .foregroundColor(Color("Color_green"))
                            Text("Device authenticated successfully!")
                                .foregroundColor(.white)
                                .font(.title)
                        }
                        .padding(10)
                    } else {
                        VStack {
                            HStack {
                                Image(systemName: "xmark.shield")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40)
                                    .foregroundColor(Color("Color_red"))
                                Text("Failed to authenticate device!")
                                    .font(.title)
                            }
                            .padding(10)
                            
                            Text("_certificates_warning")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                            
                            Text(getReasonFromPkiReturnCode(pkiReturnCode: certificateCode))
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                        }
                    }
                    
                    HStack {
                        Text("Device info:")
                            .foregroundColor(.white)
                            .font(.title)
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.white)
                            .onTapGesture(count: 1) {
                                var txt=""
                                if (certificateCode == PkiReturnCode.success){
                                    txt += "Device authenticated successfully!"
                                    txt += "\n\n"
                                } else {
                                    txt += "Failed to authenticate device!"
                                    txt += "\n\n"
                                    txt += getReasonFromPkiReturnCode(pkiReturnCode: certificateCode)
                                    txt += "\n\n"
                                }
                                txt += "Device info:"
                                txt += "\n\n"
                                txt += "Pubkey: \(certificateDic["devicePubkey"] ?? "(none)")"
                                txt += "\n\n"
                                txt += "Signature: \(certificateDic["deviceSig"] ?? "(none)")"
                                txt += "\n\n"
                                txt += "PEM: \(certificateDic["devicePem"] ?? "(none)")"
                                txt += "\n\n"
                                txt += "Subca info:"
                                txt += "\n\n"
                                txt += "Pubkey: \(certificateDic["subcaPubkey"] ?? "(none)")"
                                txt += "\n\n"
                                txt += "PEM: \(certificateDic["subcaPem"] ?? "(none)")"
                                txt += "\n\n"
                                UIPasteboard.general.string = txt
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.prepare()
                                generator.impactOccurred()
                                infoToastMessageHandler.shouldShowCopiedToClipboardMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    generator.impactOccurred()
                                }
                            }
                    }
                    VStack {
                        Text("Pubkey: \(certificateDic["devicePubkey"] ?? "(none)")")
                            .foregroundColor(.white)
                        Text("Signature: \(certificateDic["deviceSig"] ?? "(none)")")
                            .foregroundColor(.white)
                        Text("PEM: \(certificateDic["devicePem"] ?? "(none)")")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("Color_frame"), lineWidth: 4)
                    )
                    
                    Text("Subca info:")
                        .foregroundColor(.white)
                        .font(.title)
                    VStack {
                        Text("Pubkey: \(certificateDic["subcaPubkey"] ?? "(none)")")
                            .foregroundColor(.white)
                        Text("PEM: \(certificateDic["subcaPem"] ?? "(none)")")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("Color_frame"), lineWidth: 4)
                    )
                }
            }
        }
    }
    
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
}
