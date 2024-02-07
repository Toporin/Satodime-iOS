//
//  HomeView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 25/09/2023.
//

import Foundation
import SwiftUI
import SnapToScroll

class ViewStackHandlerNew: ObservableObject {
    @Published var navigationState: NavigationState = .goBackHome
}

enum NavigationState {
    case goBackHome
    case onboarding
    case takeOwnership
    case vaultInitialization
    case vaultSetupCongrats
    case cardAuthenticity
    case cardInfo
    case unseal
    case privateKey
    case reset
    case menu
    case settings
    case addFunds
}

struct HomeView: View {
    // MARK: - Properties
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    
    // current slot shown to user
    @State private var currentSlotIndex: Int = 0
    
    // let user disable specific alert prompts for the current app session
    @State var showNotOwnerAlert: Bool = true
    @State var showNotAuthenticAlert: Bool = true
    @State var showCardNeedsToBeScannedAlert: Bool = false
    // show the TakeOwnershipView if card is unclaimed, this is transmitted with CardInfoView
    @State var showTakeOwnershipAlert: Bool = true
    
    // MARK: - Literals
    let viewTitle: String = "vaults"
    
    // MARK: Body
    var body: some View {
        NavigationView {
                ZStack {
                    Constants.Colors.viewBackground
                        .ignoresSafeArea()
                    
                    if self.cardState.hasReadCard() {
                        VStack {
                            Image(self.gradientToDisplay())
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height*0.5)
                                .clipped()
                                .ignoresSafeArea()
                            Spacer()
                        }
                    }
                    
                    VStack {
                        
                        // UI: Logo + vault title + refresh button + 3-dots menu
                        HStack {
                            
                            // Logo with authenticity status
                            SatoStatusView()
                                .padding(.leading, 22)
                                .onTapGesture(count: 1){
                                    if !self.cardState.hasReadCard() {
                                        showCardNeedsToBeScannedAlert = true
                                    } else {
                                        DispatchQueue.main.async {
                                            self.viewStackHandler.navigationState = .cardAuthenticity
                                        }
                                    }
                                }
                            
                            Spacer()
                            
                            // Title
                            SatoText(text: viewTitle, style: .title)
                            
                            Spacer()
                            
                            // trigger scan card & web API
                            if !cardState.vaultArray.isEmpty {
                                Button(action: {
                                    Task {
                                        await cardState.executeQuery()
                                    }
                                    // reset flag when scanning a new card
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        showTakeOwnershipAlert = true
                                        showNotOwnerAlert = true
                                        showNotAuthenticAlert = true
                                    }
                                }) {
                                    Image("ic_refresh")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }.padding(.trailing, 8)
                            }
                            
                            // MENU
                            Button(action: {
                                self.navigateTo(destination: .menu)
                            }) {
                                Image("ic_dots_vertical")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }.padding(.trailing, 22)
                        } // end hstack
                        .frame(height: 48)
                        
                        Spacer()
                            .frame(height: 16)
                        
                        // UI: horizontal cards stack display
                        // Quick hack as HStackSnap does not support dynamic data
                        if cardState.vaultArray.isEmpty {
                            HStackSnap(alignment: .leading(20), spacing: 10) {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.clear, lineWidth: 2)
                                    .frame(width: 261, height: 197)
                                    .snapAlignmentHelper(id: 0)
                            } eventHandler: { event in
                                handleSnapToScrollEvent(event: event)
                            }
                            .frame(height: 197)
                        } else {
                            HStackSnap(alignment: .leading(20), spacing: 10) {
                                ForEach(cardState.vaultArray, id: \.self){ vault in
                                    VaultCardNew(
                                        index: vault.index,
                                        action: {
                                            if cardState.ownershipStatus == .owner {
                                                print("DEBUG click on seal new vault!")
                                                DispatchQueue.main.async {
                                                    self.viewStackHandler.navigationState = .vaultInitialization
                                                }
                                                print("DEBUG click on seal new vault AFTER!")
                                            } else {
                                                // not owner alert message
                                                self.showNotOwnerAlert = true
                                            }
                                        }
                                    )
                                        .shadow(radius: 10)
                                        .frame(width: 261, height: 197)
                                        .snapAlignmentHelper(id: vault.index)
                                }
                            } eventHandler: { event in
                                handleSnapToScrollEvent(event: event)
                            }
                            .frame(height: 197)
                        } // end HStackSnap
                        
                        Spacer()
                            .frame(height: 16)
                        
                        // UI action buttons for current slot
                        HStack(spacing: 18) {
                            if cardState.vaultArray.count > currentSlotIndex {
                                if cardState.vaultArray[currentSlotIndex].getStatus() != .uninitialized {
                                    AddFundsButton {
                                        self.navigateTo(destination: .addFunds)
                                    }
                                    
//                                    ExploreButton {
//                                        let address = cardState.vaultArray[currentSlotIndex].address
//                                        if let weblink = cardState.vaultArray[currentSlotIndex].coin.getAddressWebLink(address: address),
//                                            let weblinkUrl = URL(string: weblink) {
//                                            UIApplication.shared.open(weblinkUrl)
//                                        }
//                                    }
                                    
                                }
                                
                            
                                if cardState.vaultArray[currentSlotIndex].getStatus() == .sealed {
                                    UnsealButton {
                                        self.navigateTo(destination: .unseal)
                                    }
                                }
                                else if cardState.vaultArray[currentSlotIndex].getStatus() == .unsealed {
                                    ShowKeyButton {
                                        self.navigateTo(destination: .privateKey)
                                    }
                                    ResetButton {
                                        self.navigateTo(destination: .reset)
                                    }
                                }
                            } // end if vaultArray.count
                        } // end hstack action buttons
                        
                        Spacer()
                            .frame(height: 16)
                        
                        // UI: Tokens & NFT tabs
                        if cardState.vaultArray.count > currentSlotIndex
                            && cardState.vaultArray[currentSlotIndex].getStatus() != .uninitialized
                        {
                            AssetTabView(index: currentSlotIndex, canSelectNFT: cardState.vaultArray[currentSlotIndex].coin.supportNft)
                        } else {
                            Spacer()
                        }
                    } // end main vStack
                    
                    // MARK: - NAVIGATION
                    
                    // NAVIGATION - BASED ON STATE
                    // if card is unclaimed, propose to take ownership (only once per card scan)
                    if self.cardState.ownershipStatus == .unclaimed {
                        NavigationLink("", destination: TakeOwnershipView(showTakeOwnershipAlert: $showTakeOwnershipAlert), isActive: $showTakeOwnershipAlert)
                            .hidden()
                    }
                    
                    // NAVIGATION - CONFIG SCREENS
                    if self.viewStackHandler.navigationState == .menu {
                        NavigationLink("", destination: MenuView(showTakeOwnershipAlert: $showTakeOwnershipAlert), isActive: .constant(true)).hidden()
                    }
                    if self.viewStackHandler.navigationState == .onboarding {
                        NavigationLink("", destination: OnboardingContainerView(), isActive: .constant(true)).hidden()
                    }
                    if self.viewStackHandler.navigationState == .cardAuthenticity {
                        NavigationLink("", destination: AuthenticView(), isActive: .constant(true)).hidden()
                    }
                    if self.viewStackHandler.navigationState == .cardInfo {
                        NavigationLink("", destination: CardInfoView(), isActive: .constant(true)).hidden()
                    }
                    if self.viewStackHandler.navigationState == .settings {
                        NavigationLink("", destination: SettingsView(), isActive: .constant(true)).hidden()
                    }
                    if self.viewStackHandler.navigationState == .addFunds {
                        NavigationLink("", destination: AddFundsViewNew(index: currentSlotIndex), isActive: .constant(true)).hidden()
                    }
                    
                    // NAVIGATION - CARD ACTION SCREENS
                    if self.viewStackHandler.navigationState == .takeOwnership {
                        NavigationLink("", destination: TakeOwnershipView(showTakeOwnershipAlert: $showTakeOwnershipAlert), isActive: .constant(true)).hidden()
                    }
                    if self.viewStackHandler.navigationState == .vaultInitialization {
                        NavigationLink("", destination: VaultSetupSelectChainView(index: currentSlotIndex), isActive: .constant(true)).hidden()
                    }
                    if self.viewStackHandler.navigationState == .vaultSetupCongrats {
                        NavigationLink("", destination: VaultSetupCongratsView(index: currentSlotIndex), isActive: .constant(true)).hidden()
                    }
                    if self.viewStackHandler.navigationState == .unseal {
                        NavigationLink("", destination: UnsealView(index: currentSlotIndex), isActive: .constant(true)).hidden()
                    }
                    if self.viewStackHandler.navigationState == .privateKey {
                        NavigationLink("", destination: ShowPrivateKeyMenuView(index: currentSlotIndex), isActive: .constant(true)).hidden()
                    }
                    if self.viewStackHandler.navigationState == .reset {
                        NavigationLink("", destination: ResetView(index: currentSlotIndex), isActive: .constant(true)).hidden()
                    }
                } // ZStack
                .overlay(
                    // MARK: OVERLAY
                    Group {
                        
                        // Show scan button overlay
                        if cardState.vaultArray.isEmpty {
                            VStack {
                                
                                Spacer()
                                
                                ScanButton {
                                    Task {
                                        await cardState.executeQuery()
                                    }
                                    // reset flag when scanning a new card
                                    showTakeOwnershipAlert = true
                                    showNotOwnerAlert = true
                                    showNotAuthenticAlert = true
                                }
                                
                                Spacer()
                                
                                // Buy button
                                // TODO: put in separate file
                                Button(action: {
                                    if let weblinkUrl = URL(string: "https://satochip.io/product/satodime/") {
                                        UIApplication.shared.open(weblinkUrl)
                                    }
                                }) {
                                    HStack {
                                        Text("dontHaveASatodime")
                                        Image(systemName: "cart")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                    }
                                }
                                .padding()
                                .foregroundColor(.white)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(20)
                            }
                        }
                        
                        // Alert: user is not the owner of the card on this device
                        if self.cardState.ownershipStatus == .notOwner && showNotOwnerAlert {
                            ZStack {
                                Color.black.opacity(0.4)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        showNotOwnerAlert = false
                                    }
                                
                                SatoAlertView(
                                    isPresented: $showNotOwnerAlert,
                                    alert: SatoAlert(
                                        title: "ownership",
                                        message: "ownershipText",
                                        buttonTitle: String(localized:"moreInfo"),
                                        buttonAction: {
                                            if let url = URL(string: "https://satochip.io/satodime-ownership-explained/") {
                                                UIApplication.shared.open(url)
                                            }
                                        }
                                    )
                                )
                                    .padding([.leading, .trailing], 24)
                            }
                        } // if showNotOwnerAlert
                        
//                        // Alert: card ownership is available to claim
//                        else if self.cardState.ownershipStatus == .unclaimed && showTakeOwnershipAlert == true {
//                            SatoAlertView(
//                                isPresented: $showTakeOwnershipAlert,
//                                alert: SatoAlert(
//                                    title: "takeOwnershipAlert",
//                                    message: "takeOwnershipText",
//                                    buttonTitle: String(localized:"goToTakeOwnershipScreen"),
//                                    buttonAction: {
//                                        self.viewStackHandler.navigationState = .takeOwnership
//                                    }
//                                )
//                            )
//                        }// take ownership alert
                        
                        // Alert: show authenticity issue
                        if self.cardState.hasReadCard() && self.cardState.certificateCode != .success && showNotAuthenticAlert == true {
                            ZStack {
                                Color.black.opacity(0.4)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        showNotOwnerAlert = false
                                    }
                                SatoAlertView(
                                    isPresented: $showNotAuthenticAlert,
                                    alert: SatoAlert(
                                        title: "notAuthenticTitle",
                                        message: "notAuthenticText",
                                        buttonTitle: String(localized:"goToNotAuthenticScreen"),
                                        buttonAction: {
                                            self.viewStackHandler.navigationState = .cardInfo
                                        }
                                    )
                                )
                                .padding([.leading, .trailing], 24)
                            }//ZStack
                        }// authenticity alert
                        
                        // Alert: no card scanned
                        if showCardNeedsToBeScannedAlert {
                            ZStack {
                                Color.black.opacity(0.4)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        showNotOwnerAlert = false
                                    }
                                SatoAlertView(
                                    isPresented: $showCardNeedsToBeScannedAlert,
                                    alert: SatoAlert(
                                        title: "cardNeedToBeScannedTitle",
                                        message: "cardNeedToBeScannedMessage",
                                        buttonTitle: "",
                                        buttonAction: {},
                                        isMoreInfoBtnVisible: false
                                    )
                                )
                                .padding([.leading, .trailing], 24)
                            }//ZStack
                        }// no card scanned alert
                        
                    }// Group
                ) //overlay
            
        }// NavigationView
        .onAppear {
            if isFirstUse() {
                navigateTo(destination: .onboarding)
            }
        }
    }// body
    
    // MARK: - Helpers
    func handleSnapToScrollEvent(event: SnapToScrollEvent) {
        switch event {
            case let .didLayout(layoutInfo: layoutInfo):
            print("\(layoutInfo.keys.count) items layed out")
            case let .swipe(index: index):
            currentSlotIndex = index
            print("swiped to index: \(index)")
        }
    }
    
    func navigateTo(destination: NavigationState) {
        DispatchQueue.main.async {
            self.viewStackHandler.navigationState = destination
        }
    }
    
    func isFirstUse() -> Bool {
        let result = UserDefaults.standard.bool(forKey: Constants.Storage.isAppPreviouslyLaunched) == false
        return result
    }
    
    func gradientToDisplay() -> String {
        if cardState.vaultArray.isEmpty { return "" }
        if cardState.vaultArray[currentSlotIndex].getStatus() == .uninitialized {return ""}
        
        switch currentSlotIndex%3 {
        case 0:
            return "gradient_1"
        case 1:
            return "gradient_2"
        case 2:
            return "gradient_3"
        default:
            return "gradient_1"
        }
    }
    
} // HomeView
