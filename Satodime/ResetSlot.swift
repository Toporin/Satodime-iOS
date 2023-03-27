//
//  ResetSlot.swift
//  Satodime for iOS
//
//  Created by Satochip on 21/01/2023.
//  Copyright © 2023 Satochip S.R.L.
//

import SwiftUI

struct ResetSlot: View {
    let index: UInt8
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var reader: NfcReader
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                //Image(systemName: "clear.fill")
                Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .padding(20)
                    .foregroundColor(.red)
                    .background(Color("Color_grey"))
                    .clipShape(Circle())
                
                Text("Reset vault #\(Int64(index))?")
                    .font(.title)
                    .padding(10)
                
                Text("_reset_msg")
                    .font(.headline)
                    .padding(10)
                
                HStack {
                    Button(role: .cancel, action:{
                        self.presentationMode.wrappedValue.dismiss()
                    }){
                        Text("Cancel")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(20)
                            .background(Color("Color_grey_light"))
                            .cornerRadius(20)
                    }
                    Button(role: .destructive, action:{
                        let actionParams = ActionParams(index: index, action: "reset")
                        reader.scanForAction(actionParams: actionParams)
                        self.presentationMode.wrappedValue.dismiss()
                    }){
                        Text("Reset")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(20)
                            .background(Color("Color_red"))
                            .cornerRadius(20)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Reset vault #\(index)")
        } // NavigationView
    }// body
}

struct ResetSlot_Previews: PreviewProvider {
    static var previews: some View {
        ResetSlot(index: 0)
    }
}
