//
//  SideMenu.swift
//  Satodime for iOS
//
//  Created by Satochip on 21/01/2023.
//  Copyright © 2023 Satochip S.R.L.
//

import SwiftUI

var secondaryColor: Color = Color(.init(red: 100 / 255, green: 174 / 255, blue: 255 / 255, alpha: 1))

struct SideMenu: View {
    @Binding var isSidebarVisible: Bool
    var sideBarWidth = UIScreen.main.bounds.size.width * 0.6
    var menuColor: Color = Color(.init(red: 52 / 255, green: 70 / 255, blue: 182 / 255, alpha: 1))
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(.black.opacity(0.6))
            .opacity(isSidebarVisible ? 1 : 0)
            .animation(.easeInOut.delay(0.2), value: isSidebarVisible)
            .onTapGesture {
                isSidebarVisible.toggle()
            }
            
            content
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    var content: some View {
        HStack(alignment: .top) {
            ZStack(alignment: .top) {
                menuColor
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    Image("sidemenu-image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 160, alignment: .center)
                        //.scaledToFit()
                        //.clipShape(Capsule())
                        .shadow(color: Color.black.opacity(5.0), radius: 5, x: 5, y: 5)
                    
                    MenuLinks(isSidebarVisible: $isSidebarVisible, items: userActions)
                }
                .padding(.top, 80)
                .padding(.horizontal, 40)
            }
            .frame(width: sideBarWidth)
            .offset(x: isSidebarVisible ? 0 : -sideBarWidth)
            .animation(.default, value: isSidebarVisible)
            
            Spacer()
        }
    }

}

var userActions: [MenuItem] = [
    MenuItem(id: 1, icon: "house", text: "Home"),
    MenuItem(id: 2, icon: "info.circle", text: "Card info"),
    MenuItem(id: 3, icon: "simcard.2", text: "Transfer card"),
    MenuItem(id: 4, icon: "gearshape", text: "Settings"),
    MenuItem(id: 5, icon: "paperplane.circle", text: "Tell a friend"),
    MenuItem(id: 6, icon: "questionmark.bubble", text: "[Satodime FAQ](https://satochip.io/faq/)"),
    //MenuItem(id: 6, icon: "questionmark.bubble", text: "FAQ"),
]

struct MenuItem: Identifiable {
    var id: Int
    var icon: String
    var text: String
}

struct MenuLinks: View {
    @Binding var isSidebarVisible: Bool
    var items: [MenuItem]
    var body: some View {
        
        // todo: add image satodime
        
        VStack(alignment: .leading, spacing: 30) {
            ForEach(items) { item in
                MenuLink(isSidebarVisible: $isSidebarVisible, icon: item.icon, text: item.text)
            }
        }
        .padding(.vertical, 14)
        .padding(.leading, 8)
    }
}

struct MenuLink: View {
    @EnvironmentObject var reader: NfcReader
    @Binding var isSidebarVisible: Bool
    @State private var isSharePresented: Bool = false
    var icon: String
    var text: String
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(secondaryColor)
                .padding(.trailing, 18)
            
            Text(LocalizedStringKey(text))
                .foregroundColor(.white)
                .font(.body)
                .tint(.white)

//            if text == "FAQ" {
//                Link("Satodime FAQ", destination: URL(string: "https://satochip.io/faq/")!)
//            } else {
//                Text(LocalizedStringKey(text))
//                    .foregroundColor(.white)
//                    .font(.body)
//            }
        }
        .onTapGesture {
            print("Tapped on \(text)")
            if text == "Home" {
                isSidebarVisible.toggle()
            } else if text == "Card info" {
                isSidebarVisible.toggle()
                reader.operationType = "CardInfo"
                reader.operationRequested = true
            } else if text == "Transfer card" {
                isSidebarVisible.toggle()
                //reader.doTransfer.toggle()
                reader.operationType = "Transfer"
                reader.operationRequested = true
            } else if text == "Settings" {
                isSidebarVisible.toggle()
                //reader.doSettings.toggle()
                reader.operationType = "Settings"
                reader.operationRequested = true
            } else if text == "Tell a friend" {
                self.isSharePresented = true
            }
        }
        .sheet(isPresented: $isSharePresented, onDismiss: {
            print("Dismiss")
        }, content: {
            let msg = LocalizedStringKey("Satodime: the secure bearer crypto card! Exchange cryptos physically, easily and securely")
            ActivityViewController(activityItems: [msg, URL(string: "https://satodime.io")!])
        })
    } // View
} // MenuLink

struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            self.presentationMode.wrappedValue.dismiss()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}
