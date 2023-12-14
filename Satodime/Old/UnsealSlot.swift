////
////  UnsealSlot.swift
////  Satodime for iOS
////
////  Created by Satochip on 21/01/2023.
////  Copyright © 2023 Satochip S.R.L.
////
//
//import SwiftUI
//
//struct UnsealSlot: View {
//    let index: UInt8
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    @EnvironmentObject var reader: NfcReader
//    
//    var body: some View {
//        
//        NavigationView {
//            VStack {
//                
//                Image(systemName: "lock.open.trianglebadge.exclamationmark")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 100)
//                    .padding(30)
//                    .background(Color("Color_grey"))
//                    .foregroundColor(.orange)
//                    .clipShape(Circle())
//                
//                Text("Unseal vault #\(Int64(index))?")
//                    .font(.title)
//                    .padding(10)
//                
//                Text("_unseal_msg")
//                    .font(.headline)
//                    .padding(10)
//                
//                HStack {
//                    Button(role: .cancel, action:{
//                        self.presentationMode.wrappedValue.dismiss()}){
//                        Text("Cancel")
//                            .foregroundColor(.white)
//                            .font(.headline)
//                            .padding(20)
//                            .background(Color("Color_grey_light"))
//                            .cornerRadius(20)
//                    }
//                    Button(role: .destructive, action:{
//                        let actionParams = ActionParams(index: index, action: "unseal")
//                        reader.scanForAction(actionParams: actionParams)
//                        self.presentationMode.wrappedValue.dismiss()}){
//                        Text("Unseal")
//                            .foregroundColor(.white)
//                            .font(.headline)
//                            .padding(20)
//                            .background(Color("Color_grey"))
//                            .cornerRadius(20)
//                    }
//                }
//            }
////            .navigationBarBackButtonHidden(true)
////            .navigationTitle("Unseal vault #\(index)")
//        } // NavigationView
//    }// body
//}
