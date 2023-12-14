////
////  AcceptCard.swift
////  Satodime for iOS
////
////  Created by Satochip on 21/01/2023.
////  Copyright © 2023 Satochip S.R.L.
////
//import SwiftUI
//
//struct AcceptCard: View {
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
//                Text("_question_accept")
//                    .font(.title)
//                    .padding(10)
//                
//                Text("_msg_accept")
//                    .font(.headline)
//                    .padding(10)
//                
//                HStack {
//                    Button(role: .cancel, action:{
//                        reader.needsRefresh = true;
//                        reader.promptForTransfer.toggle(); // won't ask again next session
//                        self.presentationMode.wrappedValue.dismiss()
//                        
//                    }){
//                        Text("Cancel")
//                            .foregroundColor(.white)
//                            .font(.headline)
//                            .padding(20)
//                            .background(Color("Color_grey_light"))
//                            .cornerRadius(20)
//                    }
//                    Button(role: .destructive, action:{
//                        let actionParams = ActionParams(index: 0xFF, action: "accept")
//                        reader.scanForAction(actionParams: actionParams)
//                        //reader.needsRefresh = true;
//                        self.presentationMode.wrappedValue.dismiss()
//                    }){
//                        Text("Accept")
//                            .foregroundColor(.white)
//                            .font(.headline)
//                            .padding(20)
//                            .background(Color("Color_grey"))
//                            .cornerRadius(20)
//                    }
//                }
//            }
//            //.navigationBarBackButtonHidden(true)
//            //.navigationTitle("Transfer card ownership")
//        } // NavigationView
//    }// body
//}
//
//struct AcceptCard_Previews: PreviewProvider {
//    static var previews: some View {
//        AcceptCard()
//    }
//}
