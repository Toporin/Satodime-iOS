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
    
    var certificateCode: PkiReturnCode
    //var certificates: [String]
    var certificateDic: [String:String]
    
    var body: some View {
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
                            .padding(10)

                        Text(getReasonFromPkiReturnCode(pkiReturnCode: certificateCode))
                            .font(.headline)
                            .padding(10)
                    }
                }
                
                HStack {
                    Text("Device info:")
                        .font(.title)
                    Image(systemName: "doc.on.doc")
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
                        }
                }
                VStack {
                    Text("Pubkey: \(certificateDic["devicePubkey"] ?? "(none)")")
                    Text("Signature: \(certificateDic["deviceSig"] ?? "(none)")")
                    Text("PEM: \(certificateDic["devicePem"] ?? "(none)")")
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("Color_frame"), lineWidth: 4)
                )
//                Text(certificates[0])
//                    .padding()
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(Color("Color_frame"), lineWidth: 4)
//                    )

                Text("Subca info:")
                    .font(.title)
                VStack {
                    Text("Pubkey: \(certificateDic["subcaPubkey"] ?? "(none)")")
                    Text("PEM: \(certificateDic["subcaPem"] ?? "(none)")")
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("Color_frame"), lineWidth: 4)
                )
//                Text(certificates[1])
//                    .padding()
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(Color("Color_frame"), lineWidth: 4)
//                    )
                
            }
        }
    } // body
    
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

struct ShowCertificates_Previews: PreviewProvider {
    static var previews: some View {
        ShowCertificates(certificateCode: PkiReturnCode.success, certificateDic: ["":""])
    }
}
