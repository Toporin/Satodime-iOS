////
////  OnboardingStepView.swift
////  Onboarding
////
////  Created by Augustinas Malinauskas on 06/07/2020.
////  Copyright © 2020 Augustinas Malinauskas. All rights reserved.
////
//
//import SwiftUI
//
//struct OnboardingStepView: View {
//    var data: OnboardingDataModel
//    
//    var body: some View {
//        VStack {
//            Image("logo_horizontal")
//                .resizable()
//                .scaledToFit()
//                .padding(.bottom, 50)
//            
//            Text(data.heading)
//                .font(.system(size: 25, design: .rounded))
//                .fontWeight(.bold)
//                .padding(.bottom, 20)
//                .foregroundColor(Color("Color_gold"))
//            
//            Text(data.text)
//                .font(.system(size: 17, design: .rounded))
//                .fontWeight(.medium)
//                .multilineTextAlignment(.center)
//                .foregroundColor(Color("Color_gold"))
//            
//            Image(data.image)
//                .resizable()
//                .scaledToFit()
//                .padding(.bottom, 50)
//        }
//        .padding()
//        .contentShape(Rectangle())
//    }
//}
//
//struct OnboardingStepView_Previews: PreviewProvider {
//    static var data = OnboardingDataModel.data[0]
//    static var previews: some View {
//        OnboardingStepView(data: data)
//    }
//}
