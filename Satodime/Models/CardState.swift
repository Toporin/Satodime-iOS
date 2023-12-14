//
//  CardData.swift
//  Satodime
//
//  Created by Satochip on 01/12/2023.
//

import Foundation

//
//  NfcReader.swift
//  Satodime for iOS
//
//  Created by Satochip on 17/01/2023.
//

import Foundation
import CoreNFC
import SatochipSwift
import SwiftCryptoTools
import SwiftUI

enum SatodimeAppError: Error {
    case unlockSecretNotFound(String)
    case cardMismatch(String)
}

extension SatodimeAppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unlockSecretNotFound(_):
            return NSLocalizedString("youAreNotTheCardOwner", comment: "My error")
        case .cardMismatch(_):
            return NSLocalizedString("cardMismatch", comment: "My error")
        }
    }
}

enum OwnershipStatus: String {
    case owner
    case notOwner
    case unclaimed
    case unknown
}

class CardState: ObservableObject {
    
    @Published var isCardDataAvailable = false
    
    @Published var vaultArray: [VaultItem] = [VaultItem]() //[]
    @Published var promptForTransfer = true
    @Published var needsRefresh = true
    
    // NavigationLink
    @Published var operationRequested = false
    @Published var operationType = ""
    @Published var operationIndex = UInt8(0)
    //@Published var operationSucceeded = false
    
    // card info?
    @Published var cardStatus: CardStatus? = nil
    @Published var authentikey = [UInt8]()
    @Published var authentikeyHex = ""
    
    // certificate
    //@Published var certificates = ["", "", ""]
    @Published var certificateDic = ["":""]
    @Published var certificateCode = PkiReturnCode.unknown
    // ownership
    @Published var isOwner = false // deprecate
    @Published var ownershipStatus: OwnershipStatus = .unknown
    
    // settings
    //@Published var selectedCurrency: String = "USD" // deprecated
    //@Published var selectedFirstCurrency: String = "USD"
    //@Published var selectedSecondCurrency: String = "USD" //deprecated?
    
    // logs => use singleton?
    @Published var logArray: [String] = [String]()
    var logArrayTmp: [String] = [String]()
    //@Published var selectedLanguage: String = "English"
    //@Published var darkMode: Bool = true
    
    // fetch web data only after nfc polling has finished...
    let dispatchGroup = DispatchGroup()
    
    // For NFC session
    var session: SatocardController? // TODO: clean (used with scan())
    var sessionForAction: SatocardController? // TODO: deprecate? (used with scanForAction())
    // used with the different methods to perform actions on the card
    var cardController: SatocardController?
    //var actionParams: ActionParams = ActionParams(index:0, action: "read")
    //var actionParams: ActionParameters = ActionParameters(index:0, action: .scanCard) // TODO: deprecate?
    
    
    // settings
    // TODO: move to own preferenceService?
    let defaults = UserDefaults.standard
    var isAlreadyUsed = false
    var unlockSecretDict: [String: [UInt8]] // TODO: remove and fetch directly from default!
    
    init(){
        // settings
        isAlreadyUsed = defaults.bool(forKey: "isAlreadyUsed")
        if isAlreadyUsed {
            unlockSecretDict = defaults.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
        } else {
            // set default values
            // unlockSecret value is required to perform sensitive changes to a Satodime (seal-unseal-reset-transfer a card)
            unlockSecretDict = [String: [UInt8]]() // [String: String]
            defaults.set(unlockSecretDict, forKey: Constants.Storage.unlockSecretDict)
            defaults.set(true, forKey: "isAlreadyUsed")
        }
        print("unlockSecretDict: \(unlockSecretDict)")
    }
    
    func hasReadCard() -> Bool {
        //return self.vaultArray.count > 0
        return isCardDataAvailable
    }
    
    // TODO: put in SatochipSwift.CardStatus
    func getCardVersionInt(cardStatus: CardStatus) -> Int {
        return Int(cardStatus.protocolMajorVersion) * 256^3 +
                Int(cardStatus.protocolMinorVersion) * 256^2 +
                Int(cardStatus.appletMajorVersion) * 256 +
                Int(cardStatus.appletMinorVersion)
    }
    
    func scan(){
        print("NfcReader scan()")
        session = SatocardController(onConnect: onConnection, onFailure: onDisconnection)
        session?.start(alertMessage: String(localized: "Hold your Satodime near iPhone"))
    }
    
//    // onCompletion allows to execute statements after action has been performed
//    // TODO: return success or failure? or onSuccess/onFailure?
//    // TODO: deprecate
//    func scanForAction(actionParams: ActionParameters, onCompletion: @escaping () -> Void = { return }){
//        print("NfcReader scanForAction() \(actionParams.action)")
//        print("ActionParams: \(actionParams)")
//        self.actionParams = actionParams
//        sessionForAction = SatocardController(onConnect: onConnectionForAction, onFailure: onDisconnection)
//        sessionForAction?.start(alertMessage: String(localized: "Hold your Satodime near iPhone to perform action: \(actionParams.action.rawValue)"))
//        onCompletion()
//    }
    
    //Card connection
    func onConnection(cardChannel: CardChannel) -> Void {
        let log = LoggerService.shared
        // clear vaultArray before populating it
        //vaultArray.removeAll()
        
        log.info("Start card reading", tag: "CardState.onConnection")
        let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
        let parser = SatocardParser()
        
        do {
            try cmdSet.select().checkOK()
            let statusApdu = try cmdSet.cardGetStatus()
            let cardStatus = try CardStatus(rapdu: statusApdu)
            DispatchQueue.main.async {
                self.cardStatus = cardStatus
            }
            log.info("Status: \(cardStatus)", tag: "CardState.onConnection")
            // check if setupDone
            if cardStatus.setupDone == false { //}&& self.promptForTransfer == true {
                DispatchQueue.main.async {
                    self.isOwner = false
                    self.ownershipStatus = .unclaimed
                }
                // check version: v0.1-0.1 cannot proceed further without setup first
                if getCardVersionInt(cardStatus: cardStatus) <= 0x00010001 {
                    session?.stop(alertMessage: String(localized: "nfcSatodimeNeedsSetup"))
                    log.warning("Satodime v0.1-0.1 requires user to claim ownership to continue!", tag: "CardState.onConnection")
                    // dispatchGroup is used to wait for scan() to finish before fetching web api
                    dispatchGroup.leave()
                    return
                }
            }
            
            // check Card authenticity
            do {
                let (certificateCode, certificateDic) = try cmdSet.cardVerifyAuthenticity()
                if certificateCode == .success {
                    log.info("Card authenticated successfully!", tag: "CardState.onConnection")
                } else {
                    log.warning("Failed to authenticate card with code: \(certificateCode.rawValue)", tag: "CardState.onConnection")
                }
                DispatchQueue.main.async {
                    self.certificateCode = certificateCode
                    self.certificateDic = certificateDic
                }
            } catch {
                log.error("Failed to authenticate card with error: \(error)", tag: "CardState.onConnection")
            }
            
            // get authentikey
            let (_, authentikey, authentikeyHex) = try cmdSet.cardGetAuthentikey()
            DispatchQueue.main.async {
                self.authentikey = authentikey
                self.authentikeyHex = authentikeyHex
            }
            log.info("authentikeyHex: \(authentikeyHex)", tag: "CardState.onConnection")
            
            var satodimeStatus = try SatodimeStatus(rapdu: cmdSet.satodimeGetStatus().checkOK())
            log.info("satodimeStatus: \(satodimeStatus)", tag: "CardState.onConnection")
            
            // check for ownership
            var unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
            if let unlockSecret = unlockSecretDict[authentikeyHex]{
                satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret) // TODO: useless?
                DispatchQueue.main.async {
                    self.isOwner = true
                    self.ownershipStatus = .owner
                }
                log.info("Found an unlockSecret for this card", tag: "CardState.onConnection")
            } else {
                DispatchQueue.main.async {
                    self.isOwner = false
                    self.ownershipStatus = .notOwner
                }
                log.warning("Found no unlockSecret for this card!", tag: "CardState.onConnection")
            }
            
            // iterate on each vault
            let nbKeys = satodimeStatus.maxNumKeys
            let satodimeKeysState = satodimeStatus.satodimeKeysState
            DispatchQueue.main.async {   // <====
                // clear vaultArray before populating it
                self.isCardDataAvailable = false
                self.vaultArray.removeAll()
                self.vaultArray.reserveCapacity(nbKeys)
            }
            for index in 0 ..< nbKeys {
                let satodimeKeyslotStatus = try SatodimeKeyslotStatus(rapdu: cmdSet.satodimeGetKeyslotStatus(keyNbr: UInt8(index)).checkOK())
                log.info("keyslotStatus for vault \(index): \(satodimeKeyslotStatus)", tag: "CardState.onConnection")
                
                let pubkey: [UInt8]
                if satodimeKeysState[index] == 0x00 { // uninitialized
                    pubkey = [UInt8]()
                } else {
                    pubkey = try parser.parseSatodimeGetPubkey(rapdu: cmdSet.satodimeGetPubkey(keyNbr: UInt8(index)))
                }
                log.info("pubkey for vault \(index): \(pubkey.bytesToHex)", tag: "CardState.onConnection")
                
                var vaultItem = VaultItem(index: UInt8(index), keyslotStatus: satodimeKeyslotStatus)
                vaultItem.pubkey = pubkey
                vaultItem.address = try vaultItem.coin.pubToAddress(pubkey: pubkey)
                log.info("address for vault \(index): \(vaultItem.address)", tag: "CardState.onConnection")
                
                // apppend vaultItem to array
                DispatchQueue.main.async {   // <====
                  self.vaultArray.append(vaultItem)
                }
            }// end for index
            
            DispatchQueue.main.async {
              self.isCardDataAvailable = true
            }

        } catch let error {
            session?.stop(errorMessage: "\(String(localized: "nfcErrorOccured")) \(error.localizedDescription)")
            log.error("\(String(localized: "nfcErrorOccured")) \(error.localizedDescription)", tag: "CardState.onConnection")
        }
        
        session?.stop(alertMessage: String(localized: "nfcVaultsListSuccess"))
        log.info(String(localized: "nfcVaultsListSuccess"), tag: "CardState.onConnection")
        dispatchGroup.leave()
        
    } // end onConnection
    
    
//    // TODO: deprecate? (using distinct function for each action?)
//    func onConnectionForAction(cardChannel: CardChannel) -> Void {
//        print("START - Satodime onConnectionForAction \(actionParams.action)")
//        let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
//        let parser = SatocardParser()
//        
//        do {
//            print("START SELECT")
//            try cmdSet.select().checkOK()
//            print("START GETSTATUS")
//            let statusApdu = try cmdSet.cardGetStatus()
//            print("Status: \(cmdSet.cardStatus)")
//            if actionParams.action == .takeOwnership {
//                // check if setupDone
//                if cmdSet.cardStatus?.setupDone == false {
//                    // perform setup
//                    do {
//                        //_ = try cmdSet.cardSetup(pin_tries0: 5, pin0: pin0).checkOK()
//                        _ = try cmdSet.satodimeCardSetup().checkOK()
//                        let (_, authentikey, authentikeyHex) = try cmdSet.cardGetAuthentikey()
//                        print("Authentikey: \(authentikey)")
//                        print("AuthentikeyHex: \(authentikeyHex)")
//                        // save in defaults
//                        unlockSecretDict[authentikeyHex] = cmdSet.satodimeStatus.unlockSecret
//                        defaults.set(unlockSecretDict, forKey: Constants.Storage.unlockSecretDict)
//                        isOwner = true
//                        ownershipStatus = .owner
//                        sessionForAction?.stop(alertMessage: String(localized: "Card ownership accepted successfully!"))
//                        return
//                    } catch {
//                        print("Error during card setup: \(error)")
//                        sessionForAction?.stop(errorMessage: String(localized: "Failed to accept card ownership with error: \(error.localizedDescription)"))
//                        return
//                    }
//                } else {
//                    print("Card transer already done!")
//                    sessionForAction?.stop(alertMessage: String(localized: "Card transfer already done!"))
//                    return
//                }
//            } // if accept
//            
//            let (_, authentikey, authentikeyHex) = try cmdSet.cardGetAuthentikey()
//            print("AuthentikeyHex: \(authentikeyHex)")
//            // check authentikey did not change between sessions (i.e. it's the same card)
//            if self.authentikeyHex != authentikeyHex {
//                print("Card mismatch! \nIs this the correct card?")
//                sessionForAction?.stop(errorMessage: String(localized: "Card mismatch! \nIs this the correct card?"))
//                return
//            }
//            _ = try cmdSet.satodimeGetStatus().checkOK()
//            print("satodimeStatus: \(cmdSet.satodimeStatus)")
//            // check for ownership
//            if let unlockSecret = unlockSecretDict[authentikeyHex]{
//                cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
//                print("Found an unlockSecret for this card: \(unlockSecret)")
//            } else {
//                print("Found no unlockSecret for this card!")
//                // TODO: stop here?!
//            }
//            let nbKeys = cmdSet.satodimeStatus.maxNumKeys
//            print("nbKeys: \(nbKeys)")
//            // todo check indexReset < nbkeys
//            
//            //perform action!
//            if actionParams.action == .sealVault {
//                do {
//                    let rapdu = try cmdSet.satodimeSealKey(keyNbr: actionParams.index, entropyUser: actionParams.entropyBytes).checkOK()
//                    print("SealSlot rapdu: \(rapdu)")
//                    print("***SealSlot***")
////                    print("tokenidBytes : \(actionParams.tokenidBytes)")
////                    print("contractBytes : \(actionParams.contractBytes)")
//                    let rapdu2 = try cmdSet.satodimeSetKeyslotStatusPart0(
//                        keyNbr: actionParams.index,
//                        RFU1: 0x00, RFU2: 0x00, keyAsset: 0x00,
//                        keySlip44: actionParams.getSlip44(),
//                        keyContract: [UInt8](),
//                        keyTokenid: [UInt8]()).checkOK()
//                    print("setKeyslotStatus rapdu: \(rapdu)")
//                    // partially update status
//                    let pubkey = try parser.parseSatodimeGetPubkey(rapdu: rapdu)
//                    // todo: get Coin()
//                    DispatchQueue.main.async {
//                        self.vaultArray[Int(self.actionParams.index)].pubkey = pubkey
//                        //self.vaultArray[Int(self.actionParams.index)].keyslotStatus.asset = self.actionParams.getAssetByte()
//                        self.vaultArray[Int(self.actionParams.index)].keyslotStatus.status = 0x01
//                        self.needsRefresh = true
//                    }
//                    sessionForAction?.stop(alertMessage: String(localized: "Vault sealed successfully!"))
//                    return
//                } catch {
//                    print("SealSlot error: \(error)")
//                    sessionForAction?.stop(errorMessage: String(localized: "Failed to seal vault with error: \(error.localizedDescription)"))
//                    return
//                }
//            }
//            else if actionParams.action == .unsealVault {
//                do {
//                    let rapdu = try cmdSet.satodimeUnsealKey(keyNbr: actionParams.index).checkOK()
//                    print("UnsealSlot rapdu: \(rapdu)")
//                    // update status
//                    DispatchQueue.main.async {
//                        self.vaultArray[Int(self.actionParams.index)].keyslotStatus.status = 0x02
//                    }
//                    sessionForAction?.stop(alertMessage: String(localized: "Vault unsealed successfully!"))
//                    return
//                } catch {
//                    print("UnsealSlot error: \(error)")
//                    sessionForAction?.stop(errorMessage: String(localized: "Failed to unseal vault with error: \(error.localizedDescription)"))
//                    return
//                }
//            }
//            else if actionParams.action == .resetVault {
//                do {
//                    let rapdu = try cmdSet.satodimeResetKey(keyNbr: actionParams.index).checkOK()
//                    print("ResetSlot rapdu: \(rapdu)")
//                    // update corresponding vaultItem
//                    let satodimeKeyslotStatus = try SatodimeKeyslotStatus(rapdu: cmdSet.satodimeGetKeyslotStatus(keyNbr: actionParams.index).checkOK())
//                    print("keyslotStatus after reset: \(satodimeKeyslotStatus)")
//                    // todo: hardcode (unitialized) rapdu?
//                    let pubkey = [UInt8]()
//                    var vaultItem = VaultItem(index: actionParams.index, keyslotStatus: satodimeKeyslotStatus)
//                    vaultItem.pubkey = [UInt8]()
//                    //vaultItem.address = try vaultItem.coin.pubToAddress(pubkey: pubkey) => bug?? pubkey is []
//                    //print("address: \(vaultItem.address)")
//                    DispatchQueue.main.async {
//                        self.vaultArray[Int(self.actionParams.index)] = vaultItem
//                    }
//                    sessionForAction?.stop(alertMessage: String(localized: "Vault reset successfully!"))
//                    return
//                } catch {
//                    print("ResetSlot error: \(error)")
//                    sessionForAction?.stop(errorMessage: String(localized: "Failed to reset vault slot with error: \(error.localizedDescription)"))
//                    return
//                }
//            }
//            else if actionParams.action == .getPrivateInfo {
//                do {
//                    let rapdu = try cmdSet.satodimeGetPrivkey(keyNbr: actionParams.index).checkOK()
//                    let privkeyInfo = try parser.parseSatodimeGetPrivkey(rapdu: rapdu)
//                    // update status
//                    DispatchQueue.main.async {
//                        self.vaultArray[Int(self.actionParams.index)].privkey = privkeyInfo.privkey
//                        self.vaultArray[Int(self.actionParams.index)].entropy = privkeyInfo.entropy
//                        // todo: remove
//                        print("Debug CardState privkey: \(self.vaultArray[Int(self.actionParams.index)].privkey)")
//                        print("Debug CardState entropy: \(self.vaultArray[Int(self.actionParams.index)].entropy)")
//                    }
//                    sessionForAction?.stop(alertMessage: String(localized: "Vault privkey recovered successfully!"))
//                    print("Debug CardState: Vault privkey recovered successfully!")
//                    return
//                } catch {
//                    print("GetPrivkey error: \(error)")
//                    sessionForAction?.stop(errorMessage: String(localized: "Failed to get vault private key with error: \(error.localizedDescription)"))
//                    return
//                }
//            }
//            else if actionParams.action == .releaseOwnership {
//                do {
//                    let rapdu = try cmdSet.satodimeInitiateOwnershipTransfer().checkOK()
//                    print("TransferCard rapdu: \(rapdu)")
//                    isOwner = false
//                    ownershipStatus = .unclaimed
//                    // remove pairing secret from user defaults
//                    unlockSecretDict[authentikeyHex] = nil
//                    defaults.set(unlockSecretDict, forKey: Constants.Storage.unlockSecretDict)
//                    sessionForAction?.stop(alertMessage: String(localized: "Ownership transfer initiated successfully!"))
//                    return
//                } catch {
//                    print("TransferCard error: \(error)")
//                    sessionForAction?.stop(errorMessage: String(localized: "Failed to transfer ownership with error: \(error.localizedDescription)"))
//                    return
//                }
//            } else {
//                // should never happen?
//                print("Unknown operation requested: \(actionParams.action)")
//                sessionForAction?.stop(alertMessage: String(localized: "Satodime disconnected"))
//                print("DEBUG SATODIME - this is the end!")
//            }
//            
//        } catch let error {
//            print("An error occurred: \(error.localizedDescription)")
//            sessionForAction?.stop(errorMessage: String(localized: "An error occured: \(error.localizedDescription)"))
//            return
//        }
//        
//    } // end onConnectionForAction
    
    ///
    ///
    // MARK: TAKE OWNERSHIP
    func takeOwnership(cardAuthentikeyHex: String, onSuccess: @escaping () -> Void, onFail: @escaping () -> Void){
        let log = LoggerService.shared
        cardController = SatocardController(
            onConnect: { [weak self] cardChannel in
                guard let self = self else { return }
                log.info("Start taking ownership", tag: "CardState.takeOwnership")
                let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
                do {
                    try cmdSet.select().checkOK()
                    let statusApdu = try cmdSet.cardGetStatus()
                    let cardStatus = try CardStatus(rapdu: statusApdu)
                    log.info("Status: \(cardStatus)", tag: "CardState.takeOwnership")
                    
                    // for v0.1-0.1, authentikeyHex is not available until ownership is accepted, so this check cannot be done
                    if getCardVersionInt(cardStatus: cardStatus) > 0x00010001 {
                        let (_, _, authentikeyHex) = try cmdSet.cardGetAuthentikey()
                        // check that authentikey match with previous tap
                        guard authentikeyHex == cardAuthentikeyHex else {
                            log.error("card Mismatch: authentikey: \(authentikeyHex) expected: \(cardAuthentikeyHex)", tag: "CardState.takeOwnership")
                            throw SatodimeAppError.cardMismatch(String(localized: "nfcCardMismatch"))
                        }
                    }
                    
                    // check if setupDone
                    if cmdSet.cardStatus?.setupDone == false {
                        // perform setup
                        _ = try cmdSet.satodimeCardSetup().checkOK()
                        let (_, _, authentikeyHex) = try cmdSet.cardGetAuthentikey() // request again since authentikey is not always available
                        // save in defaults
                        var unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                        unlockSecretDict[authentikeyHex] = cmdSet.satodimeStatus.unlockSecret
                        defaults.set(unlockSecretDict, forKey: Constants.Storage.unlockSecretDict)
                        isOwner = true
                        ownershipStatus = .owner
                        cardController?.stop(alertMessage: String(localized: "Card ownership accepted successfully!"))
                        log.info("Card ownership claimed successfully for \(authentikeyHex)!", tag: "CardState.takeOwnership")
                        onSuccess()
                        return
                    } else {
                        // setup already done on card, so not possible to take ownership
                        print("Card transer already done!")
                        log.warning("Card ownership already claimed for \(authentikeyHex)!", tag: "CardState.takeOwnership")
                        cardController?.stop(alertMessage: String(localized: "nfcTransferAlreadyDone"))
                        onFail()
                        return
                    }
                } catch {
                    log.error("takeOwnership error: \(error)", tag: "CardState.takeOwnership")
                    cardController?.stop(errorMessage: "\(String(localized: "nfcOwnershipAcceptFailed")) \(error.localizedDescription)")
                    onFail()
                    return
                }
            },
            onFailure: { [weak self] error in
                // these are errors related to NFC communication
                guard let self = self else { return }
                log.error("takeOwnership NFC error: \(error)", tag: "CardState.takeOwnership")
                self.onDisconnection(error: error)
            }
        )// CardController
        cardController?.start(alertMessage: String(localized: "nfcHoldSatodime")) // TODO: change txt?
    }
    
    // MARK: RELEASE OWNERSHIP
    func releaseOwnership(cardAuthentikeyHex: String, onSuccess: @escaping () -> Void, onFail: @escaping () -> Void){
        let log = LoggerService.shared
        cardController = SatocardController(onConnect: { [weak self] cardChannel in
            guard let self = self else { return }
            log.info("Start releasing ownership", tag: "CardState.releaseOwnership")
            let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
            do {
                try cmdSet.select().checkOK()
                _ = try cmdSet.cardGetStatus()
                _ = try cmdSet.satodimeGetStatus().checkOK()
                log.info("satodimeStatus: \(cmdSet.satodimeStatus)", tag: "CardState.releaseOwnership")
                
                // TODO: put in helper method
                let (_, _, authentikeyHex) = try cmdSet.cardGetAuthentikey()
                // check that authentikey match with previous tap
                guard authentikeyHex == cardAuthentikeyHex else {
                    log.error("card Mismatch: authentikey: \(authentikeyHex) expected: \(cardAuthentikeyHex)", tag: "CardState.releaseOwnership")
                    throw SatodimeAppError.cardMismatch(String(localized: "nfcCardMismatch"))
                }
                // get unlockSecret
                var unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                if let unlockSecret = unlockSecretDict[authentikeyHex]{
                    cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                    log.info("Found an unlockSecret for this card!", tag: "CardState.releaseOwnership")
                } else {
                    throw SatodimeAppError.unlockSecretNotFound(String(localized: "nfcUnlockSecretNotFound"))
                }
                
                // releaseOwnership
                let rapdu = try cmdSet.satodimeInitiateOwnershipTransfer().checkOK()
                DispatchQueue.main.async {
                    self.isOwner = false
                    self.ownershipStatus = .unclaimed
                    // remove pairing secret from user defaults
                    unlockSecretDict[authentikeyHex] = nil
                    self.defaults.set(unlockSecretDict, forKey: Constants.Storage.unlockSecretDict)
                }
                cardController?.stop(alertMessage: String(localized: "nfcOwnershipTransferSuccess"))
                log.info(String(localized: "nfcOwnershipTransferSuccess"), tag: "CardState.releaseOwnership")
                onSuccess()
                return
            } catch {
                cardController?.stop(errorMessage: "\(String(localized: "nfcOwnershipTransferFailed")) \(error.localizedDescription)")
                log.error("\(String(localized: "nfcOwnershipTransferFailed")) \(error.localizedDescription)", tag: "CardState.releaseOwnership")
                onFail()
                return
            }
        }, onFailure: { [weak self] error in
            // these are errors related to NFC communication
            guard let self = self else { return }
            log.error("releaseOwnership NFC error: \(error)", tag: "CardState.releaseOwnership")
            self.onDisconnection(error: error)
        })
        cardController?.start(alertMessage: String(localized: "nfcHoldSatodime")) // TODO: change txt?
    }
    
    // MARK: SEAL VAULT
    func sealVault(cardAuthentikeyHex: String, index: Int, slip44: UInt32, entropyBytes: [UInt8], onSuccess: @escaping () -> Void, onFail: @escaping () -> Void) {
        let log = LoggerService.shared
        cardController = SatocardController(onConnect: { [weak self] cardChannel in
            guard let self = self else { return }
            log.info("Start sealVault operation for vault: \(index)", tag: "CardState.sealVault")
            let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
            let parser = SatocardParser()
            do {
                try cmdSet.select().checkOK()
                _ = try cmdSet.cardGetStatus()
                _ = try cmdSet.satodimeGetStatus().checkOK()
                log.info("satodimeStatus: \(cmdSet.satodimeStatus)", tag: "CardState.sealVault")
                
                // TODO: put in helper method
                let (_, _, authentikeyHex) = try cmdSet.cardGetAuthentikey()
                // check that authentikey match with previous tap
                guard authentikeyHex == cardAuthentikeyHex else {
                    log.error("card Mismatch: authentikey: \(authentikeyHex) expected: \(cardAuthentikeyHex)", tag: "CardState.sealVault")
                    throw SatodimeAppError.cardMismatch(String(localized: "nfcCardMismatch"))
                }
                // get unlockSecret
                var unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                if let unlockSecret = unlockSecretDict[authentikeyHex]{
                    cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                    log.info("Found an unlockSecret for this card!", tag: "CardState.sealVault")
                } else {
                    throw SatodimeAppError.unlockSecretNotFound(String(localized: "nfcUnlockSecretNotFound"))
                }
                
                // seal
                let rapdu = try cmdSet.satodimeSealKey(keyNbr: UInt8(index), entropyUser: entropyBytes).checkOK()
                let rapdu2 = try cmdSet.satodimeSetKeyslotStatusPart0(
                    keyNbr: UInt8(index),
                    RFU1: 0x00, RFU2: 0x00, keyAsset: 0x00,
                    keySlip44: slip44,
                    keyContract: [UInt8](),
                    keyTokenid: [UInt8]()).checkOK()
                //print("setKeyslotStatus rapdu: \(rapdu2)")
                
                // partially update status
                let pubkey = try parser.parseSatodimeGetPubkey(rapdu: rapdu)
                let satodimeKeyslotStatus = try SatodimeKeyslotStatus(rapdu: cmdSet.satodimeGetKeyslotStatus(keyNbr: UInt8(index)).checkOK())
                var vaultItem = VaultItem(index: UInt8(index), keyslotStatus: satodimeKeyslotStatus)
                let address = try vaultItem.coin.pubToAddress(pubkey: pubkey)
                vaultItem.address = address
                vaultItem.balance = 0.0
                
                // todo: get Coin()
                DispatchQueue.main.async {
                    self.vaultArray[Int(index)] = vaultItem
                }
                cardController?.stop(alertMessage: String(localized: "Vault sealed successfully!"))
                log.info("vault \(index) sealed with new pubkey: \(pubkey) & address: \(address)", tag: "CardState.sealVault")
                onSuccess()
                return
            } catch {
                cardController?.stop(errorMessage: "\(String(localized: "nfcVaultSealedFailed")) \(error.localizedDescription)") // TODO: nfcVaultSealedFailed -> nfcVaultSealFailed
                log.error("\(String(localized: "nfcVaultSealedFailed")) \(error.localizedDescription)", tag: "CardState.sealVault")
                onFail()
                return
            }
        }, onFailure: { [weak self] error in
            // these are errors related to NFC communication
            guard let self = self else { return }
            log.error("sealVault NFC error: \(error)", tag: "CardState.sealVault")
            self.onDisconnection(error: error)
        })
        cardController?.start(alertMessage: String(localized: "nfcHoldSatodime")) // TODO: change txt?
    }
    
    // MARK: UNSEAL VAULT
    func unsealVault(cardAuthentikeyHex: String, index: Int, onSuccess: @escaping () -> Void, onFail: @escaping () -> Void) {
        let log = LoggerService.shared
        cardController = SatocardController(onConnect: { [weak self] cardChannel in
            guard let self = self else { return }
            log.info("Start unsealVault operation for vault: \(index)", tag: "CardState.unsealVault")
            let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
            do {
                try cmdSet.select().checkOK()
                _ = try cmdSet.cardGetStatus()
                _ = try cmdSet.satodimeGetStatus().checkOK()
                log.info("satodimeStatus: \(cmdSet.satodimeStatus)", tag: "CardState.unsealVault")
                
                // TODO: put in helper method
                let (_, _, authentikeyHex) = try cmdSet.cardGetAuthentikey()
                // check that authentikey match with previous tap
                guard authentikeyHex == cardAuthentikeyHex else {
                    log.error("card Mismatch: authentikey: \(authentikeyHex) expected: \(cardAuthentikeyHex)", tag: "CardState.unsealVault")
                    throw SatodimeAppError.cardMismatch(String(localized: "nfcCardMismatch"))
                }
                // get unlockSecret
                var unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                if let unlockSecret = unlockSecretDict[authentikeyHex]{
                    cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                    log.info("Found an unlockSecret for this card!", tag: "CardState.unsealVault")
                } else {
                    throw SatodimeAppError.unlockSecretNotFound(String(localized: "nfcUnlockSecretNotFound"))
                }
                
                // unseal
                let rapdu = try cmdSet.satodimeUnsealKey(keyNbr: UInt8(index)).checkOK()
                //print("UnsealSlot rapdu: \(rapdu)")
                
                // update status
                DispatchQueue.main.async {
                    self.vaultArray[Int(index)].keyslotStatus.status = 0x02
                }
                cardController?.stop(alertMessage: String(localized: "nfcVaultUnsealSuccess"))
                log.info(String(localized: "nfcVaultUnsealSuccess"), tag: "CardState.unsealVault")
                onSuccess()
                return
            } catch {
                cardController?.stop(errorMessage: "\(String(localized: "nfcVaultUnsealFailed")) \(error.localizedDescription)")
                log.error("\(String(localized: "nfcVaultUnsealFailed")) \(error.localizedDescription)", tag: "CardState.unsealVault")
                log.error("DEBUG error: \(error)", tag: "CardState.unsealVault")
                onFail()
                return
            }
        }, onFailure: { [weak self] error in
            // these are errors related to NFC communication
            guard let self = self else { return }
            log.error("unsealVault NFC error: \(error)", tag: "CardState.unsealVault")
            self.onDisconnection(error: error)
        })
        cardController?.start(alertMessage: String(localized: "nfcHoldSatodime")) // TODO: change txt?
    }
    
    // MARK: RESET VAULT
    func resetVault(cardAuthentikeyHex: String, index: Int, onSuccess: @escaping () -> Void, onFail: @escaping () -> Void) {
        let log = LoggerService.shared
        cardController = SatocardController(onConnect: { [weak self] cardChannel in
            guard let self = self else { return }
            log.info("Start resetVault operation for vault: \(index)", tag: "CardState.resetVault")
            let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
            do {
                try cmdSet.select().checkOK()
                _ = try cmdSet.cardGetStatus()
                _ = try cmdSet.satodimeGetStatus().checkOK()
                log.info("satodimeStatus: \(cmdSet.satodimeStatus)", tag: "CardState.resetVault")
                
                // TODO: put in helper method
                let (_, _, authentikeyHex) = try cmdSet.cardGetAuthentikey()
                // check that authentikey match with previous tap
                guard authentikeyHex == cardAuthentikeyHex else {
                    log.error("card Mismatch: authentikey: \(authentikeyHex) expected: \(cardAuthentikeyHex)", tag: "CardState.resetVault")
                    throw SatodimeAppError.cardMismatch(String(localized: "nfcCardMismatch"))
                }
                // get unlockSecret
                var unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                if let unlockSecret = unlockSecretDict[authentikeyHex]{
                    cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                    log.info("Found an unlockSecret for this card!", tag: "CardState.resetVault")
                } else {
                    throw SatodimeAppError.unlockSecretNotFound(String(localized: "nfcUnlockSecretNotFound"))
                }
                
                let rapdu = try cmdSet.satodimeResetKey(keyNbr: UInt8(index)).checkOK()
                //print("ResetSlot rapdu: \(rapdu)")
                
                // update corresponding vaultItem
                let satodimeKeyslotStatus = try SatodimeKeyslotStatus(rapdu: cmdSet.satodimeGetKeyslotStatus(keyNbr: UInt8(index)).checkOK())
                // todo: hardcode (unitialized) rapdu?
                let pubkey = [UInt8]()
                var vaultItem = VaultItem(index: UInt8(index), keyslotStatus: satodimeKeyslotStatus)
                vaultItem.pubkey = [UInt8]()
                vaultItem.address = try vaultItem.coin.pubToAddress(pubkey: pubkey)
                DispatchQueue.main.async {
                    self.vaultArray[Int(index)] = vaultItem
                }
                cardController?.stop(alertMessage: String(localized: "Vault reset successfully!"))
                log.info("resetVault success!", tag: "CardState.resetVault")
                onSuccess()
                return
            } catch {
                cardController?.stop(errorMessage: "\(String(localized: "nfcVaultResetFailed")) \(error.localizedDescription)")
                log.error("\(String(localized: "nfcVaultResetFailed")) \(error.localizedDescription)", tag: "CardState.resetVault")
                onFail()
                return
            }
        }, onFailure: { [weak self] error in
            // these are errors related to NFC communication
            guard let self = self else { return }
            log.error("resetVault NFC error: \(error)", tag: "CardState.resetVault")
            self.onDisconnection(error: error)
        })
        cardController?.start(alertMessage: String(localized: "nfcHoldSatodime")) // TODO: change txt?
    }
    
    // MARK: GET PRIVKEY
    func getPrivateKeyNew(cardAuthentikeyHex: String, index: Int, onSuccess: @escaping (PrivateKeyResult) -> Void, onFail: @escaping () -> Void) {
        let log = LoggerService.shared
        cardController = SatocardController(onConnect: { [weak self] cardChannel in
            guard let self = self else { return }
            log.info("Start getPrivateKey operation for vault: \(index)", tag: "CardState.getPrivateKey")
            let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
            let parser = SatocardParser()
            do {
                try cmdSet.select().checkOK()
                _ = try cmdSet.cardGetStatus()
                _ = try cmdSet.satodimeGetStatus().checkOK()
                log.info("satodimeStatus: \(cmdSet.satodimeStatus)", tag: "CardState.getPrivateKey")
                
                // TODO: put in helper method
                let (_, _, authentikeyHex) = try cmdSet.cardGetAuthentikey()
                // check that authentikey match with previous tap
                guard authentikeyHex == cardAuthentikeyHex else {
                    log.error("card Mismatch: authentikey: \(authentikeyHex) expected: \(cardAuthentikeyHex)", tag: "CardState.getPrivateKey")
                    throw SatodimeAppError.cardMismatch(String(localized: "nfcCardMismatch"))
                }
                // get unlockSecret
                var unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                if let unlockSecret = unlockSecretDict[authentikeyHex]{
                    cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                    log.info("Found an unlockSecret for this card!", tag: "CardState.getPrivateKey")
                } else {
                    throw SatodimeAppError.unlockSecretNotFound(String(localized: "nfcUnlockSecretNotFound"))
                }
                
                let rapdu = try cmdSet.satodimeGetPrivkey(keyNbr: UInt8(index)).checkOK()
                let privkeyInfo = try parser.parseSatodimeGetPrivkey(rapdu: rapdu)
                
                let result = PrivateKeyResult(privkey: privkeyInfo.privkey, entropy: privkeyInfo.entropy) // TODO: merge privkeyInfo & privateKeyResult, or make privkey update directly in method?
                cardController?.stop(alertMessage: String(localized: "nfcPrivkeyRecoverSuccess"))
                log.info(String(localized: "nfcPrivkeyRecoverSuccess"), tag: "CardState.getPrivateKey")
                onSuccess(result)
                return
            } catch {
                cardController?.stop(errorMessage: "\(String(localized: "nfcPrivkeyRecoverFailed")) \(error.localizedDescription)")
                log.error("\(String(localized: "nfcPrivkeyRecoverFailed")) \(error.localizedDescription)", tag: "CardState.getPrivateKey")
                onFail()
                return
            }
        }, onFailure: { [weak self] error in
            // these are errors related to NFC communication
            guard let self = self else { return }
            log.error("getPrivateKey NFC error: \(error)", tag: "CardState.getPrivateKey")
            self.onDisconnection(error: error)
        })
        cardController?.start(alertMessage: String(localized: "nfcHoldSatodime"))
    }
    
    // MARK: ON DISCONNECTION
    func onDisconnection(error: Error) {
        //print("DEBUG SATODIME - onDisconnection")
        //print("Connection interrupted due to error: \(error)")
    }
    
    //
    // MARK: WEB APIs
    //
    
    // todo: divide in subfunctions
    func fetchDataFromWeb(index: Int) async {
        print("in fetchDataFromWeb START")
        let log = LoggerService.shared
        log.debug("Start fetching data from web for vault \(index)", tag: "CardState.fetchDataFromWeb")

        let coinInfo = vaultArray[index]
        let selectedFirstCurrency: String = coinInfo.coin.coinSymbol
        let selectedSecondCurrency: String = UserDefaults.standard.object(forKey: Constants.Storage.secondCurrency) as? String ?? "USD"
        var address = coinInfo.address
        log.debug("Using address \(address) for vault \(index)", tag: "CardState.fetchDataFromWeb")
        
        //for debug purpose
//        if coinInfo.coin.coinSymbol == "XCP" {
//            address = "1Do5kUZrTyZyoPJKtk4wCuXBkt5BDRhQJ4"
//            log.warning("Using mockup address \(address) for vault \(index)", tag: "CardState.fetchDataFromWeb")
//        } else if coinInfo.coin.coinSymbol == "ETH" {
//            //address = "0xd5b06c8c83e78e92747d12a11fcd0b03002d48cf"
//            //address = "0x86b4d38e451c707e4914ffceab9479e3a8685f98"
//            //address = "0xE71a126D41d167Ce3CA048cCce3F61Fa83274535" // cryptopunk
//            address = "0xed1bf53Ea7fD8a290A3172B6c00F1Fb3657D538F" // usdt
//            log.warning("Using mockup address \(address) for vault \(index)", tag: "CardState.fetchDataFromWeb")
//        } else if coinInfo.coin.coinSymbol == "BNB" {
//            address = "0x560eE56e87256E69AC6CC7aA00c54361fFe9af94" // usdc
//            log.warning("Using mockup address \(address) for vault \(index)", tag: "CardState.fetchDataFromWeb")
//        }
        
        // fetch balance
        log.debug("Start fetching balance", tag: "CardState.fetchDataFromWeb")
        let balance: Double?
        do {
            balance = try await coinInfo.coin.getBalance(addr: address)
            log.debug("balance for \(address): \(String(describing: balance))", tag: "CardState.fetchDataFromWeb")
            let addressUrl = URL(string: coinInfo.coin.getAddressWebLink(address: address) ?? "")
            //print ("addressUrl: \(addressUrl)")
            log.debug("addressUrl: \(String(describing: addressUrl))", tag: "CardState.fetchDataFromWeb")
            DispatchQueue.main.async {
                self.vaultArray[index].balance = balance
                self.vaultArray[index].addressUrl = addressUrl
            }
        } catch {
            balance = nil
            log.error("Failed to fetch balance for \(address) with error: \(error)", tag: "CardState.fetchDataFromWeb")
            //print("Request failed with error: \(error)")
            //print("Coin: \(coinInfo.coin.coinSymbol)")
            //logArrayTmp.append("#\(index): balance request error: \(error)")
            DispatchQueue.main.async {
                self.vaultArray[index].balance = nil
            }
        }
        
        // fetch exchange rates
        // if selectedFirstCurrency == coinInfo.coin.coinSymbol, exchange rate == 1, and the coinValueInFirstCurrency == balance
        if let balance,
            let exchangeRate1 = await coinInfo.coin.getExchangeRateBetween(coin: coinInfo.coin.coinSymbol, otherCoin: selectedFirstCurrency){
            print ("exchangeRate: \(exchangeRate1) \(selectedFirstCurrency)")
            log.debug("exchangeRate for \(address): \(String(describing: exchangeRate1)) \(selectedFirstCurrency)", tag: "CardState.fetchDataFromWeb")
            let coinValue = balance * exchangeRate1
            print("in fetchDataFromWeb [\(index)] totalValueInFirstCurrency: \(coinValue)")
            log.debug("coinValue for \(address): \(String(describing: coinValue)) \(selectedFirstCurrency)", tag: "CardState.fetchDataFromWeb")
            DispatchQueue.main.async {
                self.vaultArray[index].selectedFirstCurrency = selectedFirstCurrency
                self.vaultArray[index].coinValueInFirstCurrency = coinValue
                self.vaultArray[index].totalValueInFirstCurrency = coinValue
            }
        }
        if let balance,
            let exchangeRate2 = await coinInfo.coin.getExchangeRateBetween(coin: coinInfo.coin.coinSymbol, otherCoin: selectedSecondCurrency){
            //print ("exchangeRate: \(exchangeRate2) \(selectedSecondCurrency)")
            log.debug("exchangeRate for \(address): \(String(describing: exchangeRate2)) \(selectedSecondCurrency)", tag: "CardState.fetchDataFromWeb")
            let coinValue = balance * exchangeRate2
            //print("in fetchDataFromWeb [\(index)] totalValueInSecondCurrency: \(coinValue)")
            log.debug("coinValue for \(address): \(String(describing: coinValue)) \(selectedSecondCurrency)", tag: "CardState.fetchDataFromWeb")
            DispatchQueue.main.async {
                self.vaultArray[index].selectedSecondCurrency = selectedSecondCurrency
                self.vaultArray[index].coinValueInSecondCurrency = coinValue
                self.vaultArray[index].totalValueInSecondCurrency = coinValue
            }
        }
        
        // get list of token (including nfts)
        let assetList = await coinInfo.coin.getSimpleAssetList(addr: address)
        print("NfcReader: simpleAssetList: \(assetList)")
        log.debug("simpleAssetList for \(address): \(assetList)", tag: "CardState.fetchDataFromWeb")
        DispatchQueue.main.async {
            self.vaultArray[index].tokenList = assetList
        }
        
        // sort assets between token and nfts
        // also get value if available
        var totalTokenValueInFirstCurrency = 0.0
        var totalTokenValueInSecondCurrency = 0.0
        var nftList: [[String:String]]=[]
        var tokenList: [[String:String]]=[]
        for asset in assetList {
            if let contract = asset["contract"]{
                let nftListByContract = await coinInfo.coin.getNftList(addr: address, contract: contract)
                
                if nftListByContract.count>0 { // nft
                    for nft in nftListByContract {
                        var nftMerged = nft.merging(asset, uniquingKeysWith: { (first, _) in first })
                        nftMerged["type"] = "nft"
                        nftList.append(nftMerged)
                        //print("NfcReader: added nftMerged: \(nftMerged)")
                        log.debug("added nft for \(address): \(nftMerged)", tag: "CardState.fetchDataFromWeb")
                    }
                } else { // token
                    var assetCopy = asset
                    assetCopy["type"] = "token"
                    
                    // get price if available
                    if let tokenBalance = SatodimeUtil.getBalanceDouble(balanceString: asset["balance"], decimalsString: asset["decimals"]), //coinInfo.getTokenBalanceDouble(tokenData: asset),
                        let tokenExchangeRate = Double(asset["tokenExchangeRate"] ?? ""),
                        let currencyForExchangeRate = asset["currencyForExchangeRate"] {
                        
//                        print("in fetchDataFromWeb [\(index)] tokenBalance: \(tokenBalance)")
//                        print("in fetchDataFromWeb [\(index)] tokenExchangeRate: \(tokenExchangeRate)")
//                        print("in fetchDataFromWeb [\(index)] currencyForExchangeRate: \(currencyForExchangeRate)")
                        log.debug("tokenBalance: \(tokenBalance)", tag: "CardState.fetchDataFromWeb")
                        log.debug("tokenExchangeRate: \(tokenExchangeRate) \(currencyForExchangeRate)", tag: "CardState.fetchDataFromWeb")
                        
                        // selectedFirstCurrency
                        // TODO: cache result?
                        if let currencyExchangeRate1 = await coinInfo.coin.getExchangeRateBetween(coin: currencyForExchangeRate, otherCoin: selectedFirstCurrency)
                        {
                            //print("in fetchDataFromWeb [\(index)] currencyExchangeRate1: \(currencyExchangeRate1)")
                            //print("in fetchDataFromWeb [\(index)] selectedFirstCurrency: \(selectedFirstCurrency)")
                            log.debug("currencyExchangeRate1: \(currencyExchangeRate1) \(selectedFirstCurrency)", tag: "CardState.fetchDataFromWeb")
                            
                            let tokenValueInFirstCurrency = tokenBalance * tokenExchangeRate * currencyExchangeRate1
                            totalTokenValueInFirstCurrency += tokenValueInFirstCurrency
                            assetCopy["tokenValueInFirstCurrency"] = String(tokenValueInFirstCurrency)
                            assetCopy["firstCurrency"] = selectedFirstCurrency
                            //print("in fetchDataFromWeb tokenValueInFirstCurrency: \(tokenValueInFirstCurrency)")
                            log.debug("tokenValueInFirstCurrency: \(tokenValueInFirstCurrency) \(selectedFirstCurrency)", tag: "CardState.fetchDataFromWeb")
                        }
                        
                        // second currency
                        if let currencyExchangeRate2 = await coinInfo.coin.getExchangeRateBetween(coin: currencyForExchangeRate, otherCoin: selectedSecondCurrency)
                        {
                            log.debug("currencyExchangeRate1: \(currencyExchangeRate2) \(selectedSecondCurrency)", tag: "CardState.fetchDataFromWeb")
                            let tokenValueInSecondCurrency = tokenBalance * tokenExchangeRate * currencyExchangeRate2
                            totalTokenValueInSecondCurrency += tokenValueInSecondCurrency
                            assetCopy["tokenValueInSecondCurrency"] = String(tokenValueInSecondCurrency)
                            assetCopy["secondCurrency"] = selectedSecondCurrency
                            log.debug("tokenValueInSecondCurrency: \(tokenValueInSecondCurrency) \(selectedSecondCurrency)", tag: "CardState.fetchDataFromWeb")
                        }
                    }
                    
                    tokenList.append(assetCopy)
                    //print("NfcReader: added assetCopy: \(assetCopy)")
                    log.debug("added token for \(address): \(assetCopy)", tag: "CardState.fetchDataFromWeb")
                } // if nft else token
            } // if contract
        } // for asset
//        print("in fetchDataFromWeb [\(index)] totalTokenValueInFirstCurrency: \(totalTokenValueInFirstCurrency)")
//        print("in fetchDataFromWeb [\(index)] totalTokenValueInSecondCurrency: \(totalTokenValueInSecondCurrency)")
        log.debug("totalTokenValueInFirstCurrency for \(address): \(totalTokenValueInFirstCurrency)", tag: "CardState.fetchDataFromWeb")
        log.debug("totalTokenValueInSecondCurrency for \(address): \(totalTokenValueInSecondCurrency)", tag: "CardState.fetchDataFromWeb")
        
        DispatchQueue.main.async {[tokenList, nftList, totalTokenValueInFirstCurrency, totalTokenValueInSecondCurrency] in
            self.vaultArray[index].tokenList = tokenList
            self.vaultArray[index].nftList = nftList
            self.vaultArray[index].totalTokenValueInFirstCurrency = totalTokenValueInFirstCurrency
            self.vaultArray[index].totalTokenValueInSecondCurrency = totalTokenValueInSecondCurrency
            self.vaultArray[index].totalValueInFirstCurrency = (self.vaultArray[index].totalValueInFirstCurrency ?? 0) + totalTokenValueInFirstCurrency
            self.vaultArray[index].totalValueInSecondCurrency = (self.vaultArray[index].totalValueInSecondCurrency ?? 0) + totalTokenValueInSecondCurrency
//            print("in fetchDataFromWeb [\(index)] totalValueInFirstCurrency END: \(self.vaultArray[index].totalValueInFirstCurrency)")
//            print("in fetchDataFromWeb [\(index)] totalValueInSecondCurrency END: \(self.vaultArray[index].totalValueInSecondCurrency)")
        }
//        print("NfcReader: tokenList: \(tokenList)")
//        print("NfcReader: nftList: \(nftList)")
    }
    
    @MainActor
    func executeQuery() async {
        print("in executeQuery START")
        dispatchGroup.enter()
        self.scan()
        dispatchGroup.notify(queue: DispatchQueue.global()){
            Task {
                // fetching assets info for each vault from the web in parallel
                await withTaskGroup(of: Void.self) { group in
                    // adding tasks to the group and fetching movies
                    for index in 0..<self.vaultArray.count {
                        group.addTask {
                             await self.fetchDataFromWeb(index: index)
                        }
                    }
                    return
                }
                //self.syncLogs()
            }
        }
    }
    
//    // TODO: something?
//    func syncLogs() {
//        self.logArray.append(contentsOf: self.logArrayTmp)
//        self.logArrayTmp.removeAll()
//    }
    
}

