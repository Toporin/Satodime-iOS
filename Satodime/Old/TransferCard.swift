////
////  TransferCard.swift
////  Satodime for iOS
////
////  Created by Satochip on 30/01/2023.
////  Copyright © 2023 Satochip S.R.L.
////
//
//import SwiftUI
//
//struct TransferCard: View {
//
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    @EnvironmentObject var reader: NfcReader
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                
//                Image("card_transfer")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 100)
//                    .padding(20)
//                    .background(Color("Color_grey"))
//                    .clipShape(Circle())
//                
//                Text("Transfer card ownership ?")
//                    .font(.title)
//                    .padding(10)
//                
//                Text("_transfer_msg")
//                    .font(.headline)
//                    .padding(10)
//                
//                HStack {
//                    Button(role: .cancel, action:{
//                        reader.needsRefresh = false
//                        self.presentationMode.wrappedValue.dismiss()
//                    }){
//                        Text("Cancel")
//                            .foregroundColor(.white)
//                            .font(.headline)
//                            .padding(20)
//                            .background(Color("Color_grey_light"))
//                            .cornerRadius(20)
//                    }
//                    Button(role: .destructive, action:{
//                        reader.needsRefresh = false
//                        let actionParams = ActionParams(index: 0xFF, action: "transfer")
//                        reader.scanForAction(actionParams: actionParams)
//                        self.presentationMode.wrappedValue.dismiss()
//                    }){
//                        Text("Transfer card!")
//                            .foregroundColor(.white)
//                            .font(.headline)
//                            .padding(20)
//                            .background(Color("Color_grey"))
//                            .cornerRadius(20)
//                    }
//                }
//            }
////            .navigationBarBackButtonHidden(true)
////            .navigationTitle("Transfer card ownership")
//        } // NavigationView
//    }// body
//}
//struct TransferCard_Previews: PreviewProvider {
//    static var previews: some View {
//        TransferCard()
//    }
//}
