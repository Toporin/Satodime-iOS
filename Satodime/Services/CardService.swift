//
//  CardService.swift
//  Satodime
//
//  Created by Lionel Delvaux on 05/10/2023.
//

import Foundation
import SatochipSwift

// TODO: Needs refactoring
// MARK: - Data

struct AuthKey {
    let key: [UInt8]
    let keyHex: String
}

struct CardAuthenticity {
    let certificateCode: PkiReturnCode
    let certificateDic: [String: String]
    
    func isAuthentic() -> Bool {
        ConsoleLogger().info("isAuthentic | certificateCode: \(certificateCode.rawValue)")
        return certificateCode == .success
    }
}

struct PrivateKeyResult {
    let privkey: [UInt8]
    let entropy: [UInt8]
}

struct SealResult {
    let vaultIndex: Int
    let vaultItem: VaultItem
}

indirect enum CardActionState {
    case unknown
    case readingError(error: String)
    case silentError(error: String) // Quick workaround for the moment, I think the onFailure closure could be removed
    case notAuthentic
    case needToAcceptCard
    case cardAccepted
    case setupDone
    case noVault
    case hasVault(vaults: CardVaults)
    case isOwner
    case notOwner(vaults: CardVaults)
    case getPrivate(privateKey: PrivateKeyResult)
    case reset(updatedItem: VaultItem)
    case seal
    case sealed(result: SealResult)
    case transfer
    case unsealed(status: UInt8)
}

// MARK: - Protocol

protocol PCardService {
    func getCardActionStateStatus(completion: @escaping (CardActionState) -> Void)
    func acceptCard(completion: @escaping (CardActionState) -> Void)
    func getPrivateKey(vaultIndex: Int, completion: @escaping (CardActionState) -> Void)
    func unseal(vaultIndex: Int, completion: @escaping (CardActionState) -> Void)
    func reset(vaultIndex: Int, completion: @escaping (CardActionState) -> Void)
    func transferOwnership(completion: @escaping (CardActionState) -> Void)
    func sealVault(vaultIndex: Int,
                   for crypto: CryptoCurrency,
                   useTestNet: Bool,
                   contractBytes: [UInt8],
                   tokenidBytes: [UInt8],
                   entropyBytes: [UInt8],
                   completion: @escaping (CardActionState) -> Void)
}

// MARK: - Service

class CardService: PCardService {
    let logger = ConsoleLogger()
    var cardController: SatocardController?
    
    // TODO: Quick work around for now until refactoring of the SatocardController
    let defaultAlertMessages = SatocardController.AlertMessages(
        moreThanOneTagFound: "More than one tag was found. Please present only one tag.",
        unsupportedTagType: "Unsupported Smart Card.",
        tagConnectionError: "Connection error. Please try again."
    )
    
    func transferOwnership(completion: @escaping (CardActionState) -> Void) {
        cardController = SatocardController(alertMessages: self.defaultAlertMessages) { [weak self] cardChannel in
            guard let self = self else { return }
            let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
            _ = SatocardParser()
            do {
                print("transferOwnership START SELECT")
                try cmdSet.select().checkOK()
                print("transferOwnership START GETSTATUS")
                _ = try cmdSet.cardGetStatus()
                print("transferOwnership Status: \(String(describing: cmdSet.cardStatus))")
                
                _ = try cmdSet.satodimeGetStatus().checkOK()
                print("transferOwnership satodimeStatus: \(cmdSet.satodimeStatus)")

                var unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                
                if let auth = self.getAuthKey(cmdSet: cmdSet), let unlockSecret = unlockSecretDict[auth.keyHex]{
                    let onDeviceAuthKey = unlockSecretDict[auth.keyHex]
                    guard onDeviceAuthKey?.toHexString() != auth.keyHex else {
                        print("Card mismatch! \nIs this the correct card?")
                        cardController?.stop(errorMessage: String(localized: "Card mismatch! \nIs this the correct card?"))
                        completion(.readingError(error: String(localized: "Card mismatch! \nIs this the correct card?")))
                        return
                    }
                    
                    cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                    let rapdu = try cmdSet.satodimeInitiateOwnershipTransfer().checkOK()
                    print("transferOwnership TransferCard rapdu: \(rapdu)")
                    unlockSecretDict[auth.keyHex] = nil
                    UserDefaults.standard.set(unlockSecretDict, forKey: Constants.Storage.unlockSecretDict)
                } else {
                    print("Found no unlockSecret for this card!")
                    completion(.readingError(error: "Found no unlockSecret for this card!"))
                    return
                }
                
                cardController?.stop(alertMessage: String(localized: "Ownership transfer initiated successfully!"))
                completion(.transfer)
                return
            } catch {
                print("TransferCard error: \(error)")
                cardController?.stop(errorMessage: String(localized: "Failed to transfer ownership with error: \(error.localizedDescription)"))
                return
            }
            
        } onFailure: { [weak self] error in
            guard let self = self else { return }
            logger.error("ERROR - Satodime reading : \(error.localizedDescription)")
            cardController?.stop(alertMessage: String(localized: "An error occured : \(error.localizedDescription)"))
            completion(.readingError(error: error.localizedDescription))
        }
        cardController?.start(alertMessage: String(localized: "Hold your Satodime near iPhone"))
    }

    func getPrivateKey(vaultIndex: Int, completion: @escaping (CardActionState) -> Void) {
        cardController = SatocardController(alertMessages: self.defaultAlertMessages) { [weak self] cardChannel in
            guard let self = self else { return }
            let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
            let parser = SatocardParser()
            do {
                print("START SELECT")
                try cmdSet.select().checkOK()
                print("START GETSTATUS")
                _ = try cmdSet.cardGetStatus()
                
                _ = try cmdSet.satodimeGetStatus().checkOK()
                print("satodimeStatus: \(cmdSet.satodimeStatus)")
                
                let unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                if let auth = self.getAuthKey(cmdSet: cmdSet), let unlockSecret = unlockSecretDict[auth.keyHex]{
                    cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                    print("Found an unlockSecret for this card: \(unlockSecret)")
                } else {
                    print("Found no unlockSecret for this card!")
                }
                let rapdu = try cmdSet.satodimeGetPrivkey(keyNbr: UInt8(vaultIndex)).checkOK()
                let privkeyInfo = try parser.parseSatodimeGetPrivkey(rapdu: rapdu)
                
                let result = PrivateKeyResult(privkey: privkeyInfo.privkey, entropy: privkeyInfo.entropy)
                
                completion(.getPrivate(privateKey: result))
                cardController?.stop(alertMessage: String(localized: "Vault privkey recovered successfully!"))
                return
            } catch {
                logger.error("GetPrivkey error: \(error)")
                cardController?.stop(errorMessage: String(localized: "Failed to get vault private key with error: \(error.localizedDescription)"))
                return
            }
        } onFailure: { [weak self] error in
            guard let self = self else { return }
            self.logger.error("getPrivateKey() error: \(error.localizedDescription)")
            self.cardController?.stop(errorMessage: String(localized: "Failed to get vault private key with error: \(error.localizedDescription)"))
        }
        cardController?.start(alertMessage: String(localized: "Hold your Satodime near iPhone"))
    }
    
    func getCardActionStateStatus(completion: @escaping (CardActionState) -> Void) {
        cardController = SatocardController(alertMessages: self.defaultAlertMessages) { [weak self] cardChannel in
            guard let self = self else { return }
            let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
            
            do {
                try cmdSet.select().checkOK()
                let statusApdu = try cmdSet.cardGetStatus()
                let cardStatus = try CardStatus(rapdu: statusApdu)
                logger.info("Status: \(cardStatus)")
                
                if !cardStatus.setupDone {
                    cardController?.stop(alertMessage: String(localized: "Satodime needs setup!"))
                    logger.info("Satodime needs setup!")
                    completion(.needToAcceptCard)
                    return
                }
                
                guard let authenticity = self.isCardAuthentic(cmdSet: cmdSet), authenticity.isAuthentic() else {
                    cardController?.stop(alertMessage: String(localized: "This card is not authentic!"))
                    logger.error("Card is not authentic!")
                    completion(.notAuthentic)
                    return
                }
                
                logger.info("Card is setup")
                
                guard var cardVaults = self.getVaults(cmdSet: cmdSet, cardAuthenticity: authenticity, cardStatus: cardStatus) else {
                    logger.error("Can't read vaults")
                    completion(.readingError(error: "Can't read vaults"))
                    return
                }
                
                var emptySlotCounter = 0
                let slots = cardVaults.vaults.count
                
                cardVaults.vaults.forEach { vault in
                    if !vault.isInitialized() {
                        emptySlotCounter += 1
                    }
                }
                
                cardVaults.cardAuthenticity = authenticity
                
                if emptySlotCounter == slots || cardVaults.vaults.isEmpty {
                    logger.warning("No initialized vaults")
                    completion(.noVault)
                    cardController?.stop(alertMessage: String(localized: "This card needs to setup a first vault"))
                    return
                }
                
                logger.info("Vaults readed successfully")
                cardController?.stop(alertMessage: String(localized: "Vaults readed successfully"))
                
                if cardVaults.isOwner {
                    completion(.hasVault(vaults: cardVaults))
                    return
                } else {
                    completion(.notOwner(vaults: cardVaults))
                    return
                }
            } catch {
                logger.error("ERROR - Satodime reading : \(error.localizedDescription)")
                cardController?.stop(alertMessage: String(localized: "An error occured : \(error.localizedDescription)"))
                completion(.readingError(error: error.localizedDescription))
            }
        } onFailure: { error in
            completion(.silentError(error: error.localizedDescription))
        }
        cardController?.start(alertMessage: String(localized: "Hold your Satodime near iPhone"))
    }
    
    func acceptCard(completion: @escaping (CardActionState) -> Void) {
        cardController = SatocardController(alertMessages: self.defaultAlertMessages) { [weak self] cardChannel in
            guard let self = self else {
                return
            }
            do {
                let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
                _ = SatocardParser()
                logger.info("START SELECT")
                try cmdSet.select().checkOK()
                logger.info("START GETSTATUS")
                _ = try cmdSet.cardGetStatus()
                logger.info("Status: \(String(describing: cmdSet.cardStatus))")
                
                if cmdSet.cardStatus?.setupDone == false {
                    do {
                        _ = try cmdSet.satodimeCardSetup().checkOK()
                        let (_, authentikey, authentikeyHex) = try cmdSet.cardGetAuthentikey()
                        logger.info("Authentikey: \(authentikey)")
                        logger.info("AuthentikeyHex: \(authentikeyHex)")
                                                
                        var unlockSecretDict: [String: [UInt8]] = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                        
                        unlockSecretDict[authentikeyHex] = cmdSet.satodimeStatus.unlockSecret
                        
                        UserDefaults.standard.set(unlockSecretDict, forKey: Constants.Storage.unlockSecretDict)
                        cardController?.stop(alertMessage: String(localized: "Card ownership accepted successfully!"))
                        completion(.cardAccepted)
                        return
                    } catch {
                        logger.error("Error during card setup: \(error)")
                        cardController?.stop(errorMessage: String(localized: "Failed to accept card ownership with error: \(error.localizedDescription)"))
                        completion(.readingError(error: error.localizedDescription))
                        return
                    }
                } else {
                    logger.error("Card transer already done!")
                    cardController?.stop(alertMessage: String(localized: "Card transfer already done!"))
                    completion(.cardAccepted)
                    return
                }
            } catch {
                logger.error("Error during card setup: \(error)")
                cardController?.stop(errorMessage: String(localized: "Failed to accept card ownership with error: \(error.localizedDescription)"))
                completion(.readingError(error: error.localizedDescription))
            }
        } onFailure: { error in
            completion(.silentError(error: error.localizedDescription))
        }
        cardController?.start(alertMessage: String(localized: "Hold your Satodime near iPhone"))
    }

    func sealVault(vaultIndex: Int,
                   for crypto: CryptoCurrency,
                   useTestNet: Bool,
                   contractBytes: [UInt8] = [UInt8](),
                   tokenidBytes: [UInt8] = [UInt8](),
                   entropyBytes: [UInt8] = [UInt8](repeating: 0, count: 32), completion: @escaping (CardActionState) -> Void) {
        
        cardController = SatocardController(alertMessages: self.defaultAlertMessages) { [weak self] cardChannel in
            guard let self = self else {
                return
            }
            do {
                let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
                let parser = SatocardParser()
                
                //<==
                print("START SELECT")
                try cmdSet.select().checkOK()
                print("START GETSTATUS")
                _ = try cmdSet.cardGetStatus()
                
                _ = try cmdSet.satodimeGetStatus().checkOK()
                print("satodimeStatus: \(cmdSet.satodimeStatus)")
                // check for ownership
                let unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                if let auth = self.getAuthKey(cmdSet: cmdSet), let unlockSecret = unlockSecretDict[auth.keyHex]{
                    cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                    print("Found an unlockSecret for this card: \(unlockSecret)")
                } else {
                    print("Found no unlockSecret for this card!")
                }
                let nbKeys = cmdSet.satodimeStatus.maxNumKeys
                print("nbKeys: \(nbKeys)")
                // ==>
                
                let actionParams = ActionParams(index: UInt8(vaultIndex), action: "seal", coinString: crypto.shortIdentifier, assetString: "Coin", useTestnet: useTestNet, contractBytes: contractBytes, tokenidBytes: tokenidBytes, entropyBytes: entropyBytes)
                
                let rapdu = try cmdSet.satodimeSealKey(keyNbr: actionParams.index, entropyUser: actionParams.entropyBytes).checkOK()
                print("SealSlot rapdu: \(rapdu)")
                let rapdu2 = try cmdSet.satodimeSetKeyslotStatusPart0(keyNbr: actionParams.index, RFU1: 0x00, RFU2: 0x00, keyAsset: actionParams.getAssetByte(), keySlip44: actionParams.getSlip44(), keyContract: actionParams.contractBytes, keyTokenid: actionParams.tokenidBytes).checkOK()
                print("setKeyslotStatus rapdu: \(rapdu)")
                // partially update status
                let pubkey = try parser.parseSatodimeGetPubkey(rapdu: rapdu)
                let satodimeKeyslotStatus = try SatodimeKeyslotStatus(rapdu: cmdSet.satodimeGetKeyslotStatus(keyNbr: UInt8(vaultIndex)).checkOK())
                var newVaultItem = VaultItem(index: UInt8(vaultIndex), keyslotStatus: satodimeKeyslotStatus)
                
                newVaultItem.pubkey = pubkey
                newVaultItem.address = try newVaultItem.coin.pubToAddress(pubkey: pubkey)
                newVaultItem.keyslotStatus.status = 0x01
                newVaultItem.keyslotStatus.asset = actionParams.getAssetByte()

                let result = SealResult(vaultIndex: vaultIndex, vaultItem: newVaultItem)
                completion(.sealed(result: result))
                cardController?.stop(alertMessage: String(localized: "Vault sealed successfully!"))
                return
            } catch {
                print("SealSlot error: \(error.localizedDescription)")
                cardController?.stop(errorMessage: String(localized: "Failed to seal vault with error: \(error.localizedDescription)"))
                return
            }
        } onFailure: { error in
            completion(.silentError(error: error.localizedDescription))
        }
        cardController?.start(alertMessage: String(localized: "Hold your Satodime near iPhone"))
    }
    
    func reset(vaultIndex: Int, completion: @escaping (CardActionState) -> Void) {
        cardController = SatocardController(alertMessages: self.defaultAlertMessages) { [weak self] cardChannel in
            guard let self = self else {
                return
            }
            do {
                let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
                _ = SatocardParser()
                
                print("START SELECT")
                try cmdSet.select().checkOK()
                print("START GETSTATUS")
                _ = try cmdSet.cardGetStatus()
                
                _ = try cmdSet.satodimeGetStatus().checkOK()
                print("satodimeStatus: \(cmdSet.satodimeStatus)")
                
                let unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                if let auth = self.getAuthKey(cmdSet: cmdSet), let unlockSecret = unlockSecretDict[auth.keyHex]{
                    cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                    print("Found an unlockSecret for this card: \(unlockSecret)")
                } else {
                    print("Found no unlockSecret for this card!")
                }
                
                let rapdu = try cmdSet.satodimeResetKey(keyNbr: UInt8(vaultIndex)).checkOK()
                print("ResetSlot rapdu: \(rapdu)")
                // update corresponding vaultItem
                let satodimeKeyslotStatus = try SatodimeKeyslotStatus(rapdu: cmdSet.satodimeGetKeyslotStatus(keyNbr: UInt8(vaultIndex)).checkOK())
                print("keyslotStatus after reset: \(satodimeKeyslotStatus)")
                // todo: hardcode (unitialized) rapdu?
                let pubkey = [UInt8]()
                var vaultItem = VaultItem(index: UInt8(vaultIndex), keyslotStatus: satodimeKeyslotStatus)
                vaultItem.pubkey = [UInt8]()
                vaultItem.address = try vaultItem.coin.pubToAddress(pubkey: pubkey)
                print("address: \(vaultItem.address)")
                
                completion(.reset(updatedItem: vaultItem))
                cardController?.stop(alertMessage: String(localized: "Vault reset successfully!"))
                return
            } catch {
                print("ResetSlot error: \(error)")
                cardController?.stop(errorMessage: String(localized: "Failed to reset vault slot with error: \(error.localizedDescription)"))
                return
            }
        } onFailure: { error in
            completion(.silentError(error: error.localizedDescription))
        }
        cardController?.start(alertMessage: String(localized: "Hold your Satodime near iPhone"))
    }
    
    func unseal(vaultIndex: Int, completion: @escaping (CardActionState) -> Void) {
        cardController = SatocardController(alertMessages: self.defaultAlertMessages) { [weak self] cardChannel in
            guard let self = self else {
                return
            }
            do {
                let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
                _ = SatocardParser()
                
                print("START SELECT")
                try cmdSet.select().checkOK()
                print("START GETSTATUS")
                _ = try cmdSet.cardGetStatus()
                
                _ = try cmdSet.satodimeGetStatus().checkOK()
                print("satodimeStatus: \(cmdSet.satodimeStatus)")
                
                let unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
                if let auth = self.getAuthKey(cmdSet: cmdSet), let unlockSecret = unlockSecretDict[auth.keyHex]{
                    cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                    print("Found an unlockSecret for this card: \(unlockSecret)")
                } else {
                    print("Found no unlockSecret for this card!")
                }
                
                let rapdu = try cmdSet.satodimeUnsealKey(keyNbr: UInt8(vaultIndex)).checkOK()
                logger.info("UnsealSlot rapdu: \(rapdu)")
                
                cardController?.stop(alertMessage: String(localized: "Vault unsealed successfully!"))
                let statusToWrite = 0x02
                completion(.unsealed(status: UInt8(statusToWrite)) )
                return
            } catch {
                logger.error("UnsealSlot error: \(error)")
                cardController?.stop(errorMessage: String(localized: "Failed to unseal vault with error: \(error.localizedDescription)"))
                completion(.readingError(error: "unseal error : \(error.localizedDescription)"))
                return
            }
        } onFailure: { error in
            completion(.silentError(error: error.localizedDescription))
        }
        cardController?.start(alertMessage: String(localized: "Hold your Satodime near iPhone"))
    }
    
    func getVaults(cmdSet: SatocardCommandSet, cardAuthenticity: CardAuthenticity, cardStatus: CardStatus) -> CardVaults? {
        let parser = SatocardParser()
        var vaultArray: [VaultItem] = []
        var isOwner = false
        
        do {
            let unlockSecretDict = UserDefaults.standard.object(forKey: Constants.Storage.unlockSecretDict) as? [String: [UInt8]] ?? [String: [UInt8]]()
            var satodimeStatus = try SatodimeStatus(rapdu: cmdSet.satodimeGetStatus().checkOK())
            logger.info("satodimeStatus: \(satodimeStatus)")
            if let auth = self.getAuthKey(cmdSet: cmdSet), let unlockSecret = unlockSecretDict[auth.keyHex]{
                satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                logger.info("Found an unlockSecret for this card: \(unlockSecret)")
                isOwner = true
            }
            
            let nbKeys = satodimeStatus.maxNumKeys
            logger.info("nbKeys: \(nbKeys)")
            let satodimeKeysState = satodimeStatus.satodimeKeysState
            logger.info("satodimeKeysState: \(satodimeKeysState)")
            // TODO: Sync logs ?
            /*DispatchQueue.main.async {
                self.syncLogs()
            }*/
            for index in 0 ..< nbKeys {
                logger.info("index: \(index)")
                
                let satodimeKeyslotStatus = try SatodimeKeyslotStatus(rapdu: cmdSet.satodimeGetKeyslotStatus(keyNbr: UInt8(index)).checkOK())
                logger.info("keyslotStatus: \(satodimeKeyslotStatus)")
                
                let pubkey: [UInt8]
                if satodimeKeysState[index] == 0x00 {
                    pubkey = [UInt8]()
                } else {
                    pubkey = try parser.parseSatodimeGetPubkey(rapdu: cmdSet.satodimeGetPubkey(keyNbr: UInt8(index)))
                }
                logger.info("pubkey: \(pubkey)")
                
                var vaultItem = VaultItem(index: UInt8(index), keyslotStatus: satodimeKeyslotStatus)
                vaultItem.pubkey = pubkey
                vaultItem.address = try vaultItem.coin.pubToAddress(pubkey: pubkey)
                logger.info("address: \(vaultItem.address)")
                
                vaultArray.append(vaultItem)
                
                logger.info("End for index: \(index)")
            }
            let versionString = getCardVersionString(cardStatus: cardStatus)
            let result = CardVaults(isOwner: isOwner, isCardAuthentic: cardAuthenticity.isAuthentic(), cardVersion: versionString, vaults: vaultArray)
            return result
        } catch {
            logger.error("ERROR - getVaults : \(error.localizedDescription)")
        }
        
        return nil
    }
    
    private func isCardAuthentic(cmdSet: SatocardCommandSet) -> CardAuthenticity? {
        do {
            let (certificateCode, certificateDic) = try cmdSet.cardVerifyAuthenticity()
            let result = CardAuthenticity(certificateCode: certificateCode, certificateDic: certificateDic)
            return result
        } catch {
            logger.error("Failed to authenticate card with error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getAuthKey(cmdSet: SatocardCommandSet) -> AuthKey?  {
        do {
            let (_, authentikey, authentikeyHex) = try cmdSet.cardGetAuthentikey()
            logger.info("Authentikey: \(authentikey)")
            logger.info("AuthentikeyHex: \(authentikeyHex)")
            let authKey = AuthKey(key: authentikey, keyHex: authentikeyHex)
            return authKey
        } catch {
            logger.error("Failed to get auth key with error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getCardVersionString(cardStatus: CardStatus) -> String {
        let str = "Satodime v\(cardStatus.protocolMajorVersion).\(cardStatus.protocolMinorVersion)-\(cardStatus.appletMajorVersion).\(cardStatus.appletMinorVersion)"
        return str
    }
}
