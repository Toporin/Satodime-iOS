//
//  CardData.swift
//  Satodime
//
//  Created by Satochip on 01/12/2023.
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
    // vaults info as array
    @Published var vaultArray: [VaultItem] = [VaultItem]() //[]
    // card info
    @Published var cardStatus: CardStatus? = nil
    @Published var authentikeyHex = ""
    // ownership
    @Published var ownershipStatus: OwnershipStatus = .unknown
    // certificate
    @Published var certificateDic = ["":""]
    @Published var certificateCode = PkiReturnCode.unknown
    
    // DEBUG mode
    let DEBUGGING_MODE = false
    
    // fetch web data only after nfc polling has finished...
    let dispatchGroup = DispatchGroup()
    
    // For NFC session
    var session: SatocardController? // TODO: clean (used with scan())
    // used with the different methods to perform actions on the card
    var cardController: SatocardController?
    
    func hasReadCard() -> Bool {
        //return self.vaultArray.count > 0
        return isCardDataAvailable
    }
    
    // TODO: put in SatochipSwift.CardStatus
    func getCardVersionInt(cardStatus: CardStatus) -> Int {
        return Int(cardStatus.protocolMajorVersion) * (1<<24) +
                Int(cardStatus.protocolMinorVersion) * (1<<16) +
                Int(cardStatus.appletMajorVersion) * (1<<8) +
                Int(cardStatus.appletMinorVersion)
    }
    
    func scan(){
        //print("NfcReader scan()")
        DispatchQueue.main.async {
            // reset cardState info
            self.ownershipStatus = .unknown
            self.certificateCode = PkiReturnCode.unknown
            self.authentikeyHex = ""
            // clear vaultArray before populating it
            self.isCardDataAvailable = false
            self.vaultArray.removeAll()
        }
        session = SatocardController(onConnect: onConnection, onFailure: onDisconnection)
        session?.start(alertMessage: String(localized: "nfcHoldSatodime"))
    }
    
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
            let cardStatus = CardStatus(rapdu: statusApdu)
            DispatchQueue.main.async {
                self.cardStatus = cardStatus
            }
            log.info("Status: \(cardStatus)", tag: "CardState.onConnection")
            // check if setupDone
            if let cardStatus = cardStatus {
                if cardStatus.setupDone == false {
                    DispatchQueue.main.async {
                        self.ownershipStatus = .unclaimed
                    }
                    // check version: v0.1-0.1 cannot proceed further without setup first
                    print("DEBUG CardVersionInt: \(getCardVersionInt(cardStatus: cardStatus))")
                    if getCardVersionInt(cardStatus: cardStatus) <= 0x00010001 {
                        session?.stop(alertMessage: String(localized: "nfcSatodimeNeedsSetup"))
                        log.warning("Satodime v0.1-0.1 requires user to claim ownership to continue!", tag: "CardState.onConnection")
                        // dispatchGroup is used to wait for scan() to finish before fetching web api
                        dispatchGroup.leave()
                        return
                    }
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
            let (_, _, authentikeyHex) = try cmdSet.cardGetAuthentikey()
            DispatchQueue.main.async {
                self.authentikeyHex = authentikeyHex
            }
            log.info("authentikeyHex: \(authentikeyHex)", tag: "CardState.onConnection")
            
            var satodimeStatus = try SatodimeStatus(rapdu: cmdSet.satodimeGetStatus().checkOK())
            log.info("satodimeStatus: \(satodimeStatus)", tag: "CardState.onConnection")
            
            // check for ownership
            if let cardStatus = cardStatus {
                if cardStatus.setupDone {
                    let unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                    if let unlockSecret = unlockSecretDict[authentikeyHex]{
                        satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret) // TODO: useless?
                        DispatchQueue.main.async {
                            self.ownershipStatus = .owner
                        }
                        log.info("Found an unlockSecret for this card", tag: "CardState.onConnection")
                    } else if self.ownershipStatus == .unknown {
                        DispatchQueue.main.async {
                            self.ownershipStatus = .notOwner
                        }
                        log.warning("Found no unlockSecret for this card!", tag: "CardState.onConnection")
                    } // if self.ownershipStatus == .unclaimed, do nothing
                }
            }
                    
            // iterate on each vault
            let nbKeys = satodimeStatus.maxNumKeys
            let satodimeKeysState = satodimeStatus.satodimeKeysState
            DispatchQueue.main.async {
//                // clear vaultArray before populating it
//                self.isCardDataAvailable = false
//                self.vaultArray.removeAll()
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
            
            session?.stop(alertMessage: String(localized: "nfcVaultsListSuccess"))
            log.info(String(localized: "nfcVaultsListSuccess"), tag: "CardState.onConnection")
            dispatchGroup.leave()
            self.fetchVaultsData()
            
        } catch let error {
            session?.stop(errorMessage: "\(String(localized: "nfcErrorOccured"))")
            log.error("\(String(localized: "nfcErrorOccured")) \(error.localizedDescription)", tag: "CardState.onConnection")
            dispatchGroup.leave()
        }
        
        
        
    } // end onConnection
    
    private func fetchVaultsData() {
        for index in 0..<self.vaultArray.count where self.vaultArray[index].isInitialized() {
            Task {
                await self.fetchDataFromWeb(index: index)
            }
        }
    }
    
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
                    let cardStatus = CardStatus(rapdu: statusApdu)
                    log.info("Status: \(cardStatus)", tag: "CardState.takeOwnership")
                    
                    // for v0.1-0.1, authentikeyHex is not available until ownership is accepted, so this check cannot be done
                    if let cardStatus = cardStatus {
                        if getCardVersionInt(cardStatus: cardStatus) > 0x00010001 {
                            let (_, _, authentikeyHex) = try cmdSet.cardGetAuthentikey()
                            // check that authentikey match with previous tap
                            guard authentikeyHex == cardAuthentikeyHex else {
                                log.error("card Mismatch: authentikey: \(authentikeyHex) expected: \(cardAuthentikeyHex)", tag: "CardState.takeOwnership")
                                throw SatodimeAppError.cardMismatch(String(localized: "nfcCardMismatch"))
                            }
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
                        UserDefaults.standard.set(unlockSecretDict, forKey: Constants.Storage.unlockSecretDict)
                        DispatchQueue.main.async {
                            self.ownershipStatus = .owner
                        }
                        cardController?.stop(alertMessage: String(localized: "nfcOwnershipAcceptSuccess"))
                        log.info("Card ownership claimed successfully for \(authentikeyHex)!", tag: "CardState.takeOwnership")
                        onSuccess()
                        return
                    } else {
                        // setup already done on card, so not possible to take ownership
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
                    self.ownershipStatus = .unclaimed
                    // remove pairing secret from user defaults
                    unlockSecretDict[authentikeyHex] = nil
                    UserDefaults.standard.set(unlockSecretDict, forKey: Constants.Storage.unlockSecretDict)
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
                let unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
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
                vaultItem.coinValueInSecondCurrency = 0.0
                vaultItem.selectedSecondCurrency = UserDefaults.standard.object(forKey: Constants.Storage.secondCurrency) as? String ?? "USD"
                
                // todo: get Coin()
                DispatchQueue.main.async {
                    self.vaultArray[Int(index)] = vaultItem
                }
                cardController?.stop(alertMessage: String(localized: "nfcVaultSealedSuccess"))
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
                let unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
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
                let unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
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
    func getPrivateKeyNew(cardAuthentikeyHex: String, index: Int, onSuccess: @escaping (SatodimePrivkeyInfo) -> Void, onFail: @escaping () -> Void) {
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
                let unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                if let unlockSecret = unlockSecretDict[authentikeyHex]{
                    cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                    log.info("Found an unlockSecret for this card!", tag: "CardState.getPrivateKey")
                } else {
                    throw SatodimeAppError.unlockSecretNotFound(String(localized: "nfcUnlockSecretNotFound"))
                }
                
                let rapdu = try cmdSet.satodimeGetPrivkey(keyNbr: UInt8(index)).checkOK()
                let privkeyInfo = try parser.parseSatodimeGetPrivkey(rapdu: rapdu)
                
                cardController?.stop(alertMessage: String(localized: "nfcPrivkeyRecoverSuccess"))
                log.info(String(localized: "nfcPrivkeyRecoverSuccess"), tag: "CardState.getPrivateKey")
                onSuccess(privkeyInfo)
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
    }
    
    //
    // MARK: WEB APIs
    //

    func fetchDataFromWeb(index: Int) async {
        let log = LoggerService.shared
        log.debug("Start fetching data from web for vault \(index)", tag: "CardState.fetchDataFromWeb")
        
        guard index >= 0 && index < vaultArray.count else {
            log.error("Index out of bounds", tag: "CardState.fetchDataFromWeb")
            return
        }
        
        let coinInfo = vaultArray[index]
        let selectedFirstCurrency = coinInfo.coin.coinSymbol
        let selectedSecondCurrency = UserDefaults.standard.string(forKey: Constants.Storage.secondCurrency) ?? "USD"
        
        await updateVaultInfo(for: index, with: coinInfo, selectedFirstCurrency: selectedFirstCurrency, selectedSecondCurrency: selectedSecondCurrency)
    }
    
    // Update vault information including balance, exchange rates, and asset list
    private func updateVaultInfo(for index: Int, with coinInfo: VaultItem, selectedFirstCurrency: String, selectedSecondCurrency: String) async {
        let log = LoggerService.shared
        var address = coinInfo.address

        //for debug purpose only!
        if DEBUGGING_MODE {
            if coinInfo.coin.coinSymbol == "BTC" {
                address = "bc1ql49ydapnjafl5t2cp9zqpjwe6pdgmxy98859v2" // whale
            } else if coinInfo.coin.coinSymbol == "LTC" {
                address = "ltc1qr07zu594qf63xm7l7x6pu3a2v39m2z6hh5pp4t" // whale
            } else if coinInfo.coin.coinSymbol == "BCH" {
                address = "1PUwPCNqKiC6La8wtbJEAhnBvtc8gdw19h" // whale
            } else if coinInfo.coin.coinSymbol == "XCP" {
                address = "1Do5kUZrTyZyoPJKtk4wCuXBkt5BDRhQJ4"
            } else if coinInfo.coin.coinSymbol == "ETH" {
                //address = "0xd5b06c8c83e78e92747d12a11fcd0b03002d48cf"
                //address = "0x86b4d38e451c707e4914ffceab9479e3a8685f98"
                //address = "0xE71a126D41d167Ce3CA048cCce3F61Fa83274535" // cryptopunk
                address = "0xed1bf53Ea7fD8a290A3172B6c00F1Fb3657D538F" // usdt
                //address = "0x2c4ebd4b21736e992f3efeb55de37ae66457199d" // grolex nft
            } else if coinInfo.coin.coinSymbol == "POL" {
                //address = "0x8db853Aa2f01AF401e10dd77657434536735aC62"
                //address = "0x86d22A8219De3683CF188778CDAdEE62D1442033"
                address = "0xE976c3052Df18cc2Dc878b9bc3191Bba68Ef3d80" // DolZ nft
                //address = "0x440D4955a914D5e29F861aC024A608aE41c56cB6" // PookyBall nft contract
                //address = "0xd7f1cbca340c831d77c0d8d3dc843a07873ade44" // PookyBall nft vault
                //address = "0xF977814e90dA44bFA03b6295A0616a897441aceC" // Binance hot wallet with USDT
            } else if coinInfo.coin.coinSymbol == "BNB" {
                address = "0x560eE56e87256E69AC6CC7aA00c54361fFe9af94" // usdc
            }
            log.warning("Using mockup address \(address) for vault \(index)", tag: "CardState.updateVaultInfo")
        } else {
            log.debug("Using address \(address) for vault \(index)", tag: "CardState.updateVaultInfo")
        }
        
        await updateCoinInfoFromApi(for: index, coinInfo: coinInfo, address: address)
        await updateAssetsFromApi(for: index, coinInfo: coinInfo, address: address)
    }
    
    // fetch coinf info from web (balance, url, rates)
    private func updateCoinInfoFromApi(for index: Int, coinInfo: VaultItem, address: String) async {
        let log = LoggerService.shared
        do {
            let coin = coinInfo.coin
            
            // coin balance
            let coinInfoDic = try await coin.getCoinInfo(addr: address)
            let addressUrl = URL(string: coin.getAddressWebLink(addr: address) ?? "")
            let balanceStr: String? = coinInfoDic["balance"]
            log.debug("Fetched balance: \(String(describing: balanceStr)) and URL: \(String(describing: addressUrl))", tag: "CardState.updateCoinInfoFromApi")
            
            // balance in first currency: in native coin
            let selectedFirstCurrency = coinInfo.coin.coinSymbol
            let coinValueInFirstCurrency: Double? = Double(balanceStr ?? "")
            
            // balance in second currency
            let selectedSecondCurrency = UserDefaults.standard.string(forKey: Constants.Storage.secondCurrency) ?? "USD"
            var valueInSecondCurrency: Double? = nil
            if let coinValueInFirstCurrency {
                if coinValueInFirstCurrency == 0 {
                    valueInSecondCurrency = 0
                } else {
                    if let exchangeRate2 = await coin.getExchangeRateBetween(coin: coin.coinSymbol, otherCoin: selectedSecondCurrency){
                        valueInSecondCurrency = coinValueInFirstCurrency * exchangeRate2
                    }
                }
            }
            let coinValueInSecondCurrency: Double? = valueInSecondCurrency
            
            DispatchQueue.main.async {
                self.vaultArray[index].balance = coinValueInFirstCurrency
                self.vaultArray[index].addressUrl = addressUrl
                
                self.vaultArray[index].selectedFirstCurrency = selectedFirstCurrency
                self.vaultArray[index].coinValueInFirstCurrency = coinValueInFirstCurrency
                
                self.vaultArray[index].selectedSecondCurrency = selectedSecondCurrency
                self.vaultArray[index].coinValueInSecondCurrency = coinValueInSecondCurrency
            }
            log.debug("Updated exchange rates and values for vault \(index)", tag: "CardState.updateExchangeRatesAndValues")
            
        } catch {
            log.error("Failed to fetch balance with error: \(error)", tag: "CardState.fetchDataFromWeb")
        }
    }
    
    private func updateAssetsFromApi(for index: Int, coinInfo: VaultItem, address: String) async {
        let log = LoggerService.shared
        let coin = coinInfo.coin
        do {
            let assetList = try await coin.getAssetList(addr: address)
            log.debug("Fetched asset list for \(address): \(assetList)", tag: "CardState.fetchAndSortAssets")
            
            var nftList: [[String: String]] = []
            var tokenList: [[String: String]] = []
            
            let selectedFirstCurrency = coin.coinSymbol
            let selectedSecondCurrency = UserDefaults.standard.string(forKey: Constants.Storage.secondCurrency) ?? "USD"
            
            for asset in assetList {
                if let contract = asset["contract"]{
                    
                    var assetCopy = asset
                    var assetType = assetCopy["type"]
                    // get rates if available
                    if let assetBalance = SatodimeUtil.getBalanceDouble(balanceString: assetCopy["balance"], decimalsString: "0"),
                       let exchangeRate = Double(assetCopy["exchangeRate"] ?? ""),
                       let currency = assetCopy["currencyForExchangeRate"]
                    {
                        log.debug("assetBalance: \(assetBalance)", tag: "CardState.fetchDataFromWeb")
                        log.debug("exchangeRate: \(exchangeRate) \(currency)", tag: "CardState.fetchDataFromWeb")
                        
                        // selectedFirstCurrency
                        // TODO: cache result?
                        if let currencyExchangeRate1 = await coin.getExchangeRateBetween(coin: currency, otherCoin: selectedFirstCurrency)
                        {
                            log.debug("currencyExchangeRate1: \(currencyExchangeRate1) \(selectedFirstCurrency)", tag: "CardState.fetchDataFromWeb")
                            let tokenValueInFirstCurrency = assetBalance * exchangeRate * currencyExchangeRate1
                            assetCopy["tokenValueInFirstCurrency"] = String(tokenValueInFirstCurrency)
                            assetCopy["firstCurrency"] = selectedFirstCurrency
                            log.debug("tokenValueInFirstCurrency: \(tokenValueInFirstCurrency) \(selectedFirstCurrency)", tag: "CardState.fetchDataFromWeb")
                        }
                        
                        // second currency
                        if let currencyExchangeRate2 = await coin.getExchangeRateBetween(coin: currency, otherCoin: selectedSecondCurrency)
                        {
                            log.debug("currencyExchangeRate1: \(currencyExchangeRate2) \(selectedSecondCurrency)", tag: "CardState.fetchDataFromWeb")
                            let tokenValueInSecondCurrency = assetBalance * exchangeRate * currencyExchangeRate2
                            assetCopy["tokenValueInSecondCurrency"] = String(tokenValueInSecondCurrency)
                            assetCopy["secondCurrency"] = selectedSecondCurrency
                            log.debug("tokenValueInSecondCurrency: \(tokenValueInSecondCurrency) \(selectedSecondCurrency)", tag: "CardState.fetchDataFromWeb")
                        }
                    }
                    
                    if assetType == "nft" {
                        nftList.append(assetCopy)
                        log.debug("added nft for \(address): \(assetCopy)", tag: "CardState.fetchAndSortAssetsFromApi")
                    } else {
                        assetCopy["type"] = "token"
                        tokenList.append(assetCopy)
                        log.debug("added token for \(address): \(assetCopy)", tag: "CardState.fetchAndSortAssetsFromApi")
                    }
                } // if contract
            } // for asset
            
            DispatchQueue.main.async {
                self.vaultArray[index].tokenList = tokenList
                self.vaultArray[index].nftList = nftList
            }
        } catch {
            log.error("Failed to fetch asset list with error: \(error)", tag: "CardState.fetchAndSortAssetsFromApi")
        }
        
        log.debug("Sorted assets into tokens and NFTs for vault \(index)", tag: "CardState.fetchAndSortAssetsFromApi")
    }
    
    @MainActor
    func executeQuery() async -> NetworkResult {
        print("in executeQuery START")
        dispatchGroup.enter()
        self.scan()
        return Reachability.shared.isConnected ? .success : .failure
    }
}
