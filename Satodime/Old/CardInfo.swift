////
////  CardInfo.swift
////  Satodime for iOS
////
////  Created by Satochip on 09/02/2023.
////  Copyright © 2023 Satochip S.R.L.
////
//
//import SwiftUI
//import SatochipSwift
//
//struct CardInfo: View {
//    
//    @EnvironmentObject var reader: NfcReader
//    @State var showCertificate = false
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                
//                Image(systemName: "creditcard")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 100)
//                    .padding(20)
//                    .background(Color("Color_grey"))
//                    .clipShape(Circle())
//                
//                Text("Card info")
//                    .font(.title)
//                    .padding(10)
//                
//                Text("Ownership status:")
//                    .font(.headline)
//                    .padding(10)
//                
//                VStack(alignment: .leading) {
//                    if (reader.isOwner){
//                        Text("You are the card owner")
//                            .font(.headline)
//                            .padding(20)
//                            .background(Color.green)
//                            .cornerRadius(20)
//                        
//                    } else {
//                        Text("You are NOT the card owner!")
//                            .font(.headline)
//                            .padding(20)
//                            .background(Color.orange)
//                            .cornerRadius(20)
//                    }
//                }
//                
//                Text("Card version:")
//                    .font(.headline)
//                    .padding(10)
//                
//                VStack(alignment: .leading) {
//                    Text(getCardVersionString(cardStatus: reader.cardStatus))
//                        .font(.headline)
//                        .padding(20)
//                        .background(Color.green)
//                        .cornerRadius(20)
//                }
//                
//                Text("Authenticity status:")
//                    .font(.headline)
//                    .padding(10)
//                
//                VStack(alignment: .leading) {
//                    if (reader.certificateCode == PkiReturnCode.success){
//                        Text("This card is authentic!")
//                            .font(.headline)
//                            .padding(20)
//                            .background(Color.green)
//                            .cornerRadius(20)
//                    } else {
//                        Text("This card is NOT authentic!")
//                            .font(.headline)
//                            .padding(20)
//                            .background(Color.red)
//                            .cornerRadius(20)
//                    }
//                }
//                
//                Button(action: {
//                    showCertificate = true
//                    print("Button show certificate")
//                }) {
//                    HStack{
//                        Image(systemName: "magnifyingglass.circle")
//                        Text("Show certificate details")
//                    }
//                }
//                .padding(20)
//                .foregroundColor(.white)
//                .background(Color.gray)
//                //.cornerRadius(.infinity)
//                .cornerRadius(20)
//                .buttonStyle(.borderless)
//                
//            } // VStack
//            .background(
//                NavigationLink(destination: ShowCertificates(certificateCode: reader.certificateCode, certificateDic: reader.certificateDic), isActive: $showCertificate){EmptyView()}
//            )
//        } // NavigationView
//    }// body
//    
//    func getCardVersionString(cardStatus: CardStatus?) -> String {
//        if let cardStatus = cardStatus {
//            let str = "Satodime v\(cardStatus.protocolMajorVersion).\(cardStatus.protocolMinorVersion)-\(cardStatus.appletMajorVersion).\(cardStatus.appletMinorVersion)"
//            return str
//        } else {
//            return "n/a"
//        }
//    }
//}
//
//struct CardInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        CardInfo()
//    }
//}
