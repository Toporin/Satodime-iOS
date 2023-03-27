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

class NfcReader: ObservableObject {

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
    @Published var isOwner = false
    
    // settings
    @Published var selectedCurrency: String = "USD"
    @Published var logArray: [String] = [String]()
    var logArrayTmp: [String] = [String]()
    //@Published var selectedLanguage: String = "English"
    //@Published var darkMode: Bool = true
    
    // fetch web data only after nfc polling has finished...
    let dispatchGroup = DispatchGroup()
    
    var session: SatocardController?
    var sessionForAction: SatocardController?
    var actionParams: ActionParams = ActionParams(index:0, action: "read")
    
    // settings
    let defaults = UserDefaults.standard
    var isAlreadyUsed = false
    var unlockSecretDict: [String: [UInt8]]
    
    init(){
        // settings
        isAlreadyUsed = defaults.bool(forKey: "isAlreadyUsed")
        if isAlreadyUsed {
            unlockSecretDict = defaults.object(forKey: "unlockSecretDict") as? [String: [UInt8]] ?? [String: [UInt8]]()
        } else {
            // set default values
            // unlockSecret value is required to perform sensitive changes to a Satodime (seal-unseal-reset-transfer a card)
            unlockSecretDict = [String: [UInt8]]() // [String: String]
            defaults.set(unlockSecretDict, forKey: "unlockSecretDict")
            defaults.set(true, forKey: "isAlreadyUsed")
        }
        print("unlockSecretDict: \(unlockSecretDict)")
    }
    
    func scan(){
        print("NfcReader scan()")
        session = SatocardController(onConnect: onConnection, onFailure: onDisconnection)
        session?.start(alertMessage: String(localized: "Hold your Satodime near iPhone"))
    }
    
    func scanForAction(actionParams: ActionParams){
        print("NfcReader scanForAction() \(actionParams.action)")
        print("ActionParams: \(actionParams)")
        self.actionParams = actionParams
        sessionForAction = SatocardController(onConnect: onConnectionForAction, onFailure: onDisconnection)
        sessionForAction?.start(alertMessage: String(localized: "Hold your Satodime near iPhone to perform action: \(actionParams.action)"))
    }
    
    //Card connection
    func onConnection(cardChannel: CardChannel) -> Void {
        // clear vaultArray before populating it
        //vaultArray.removeAll()
        
        print("START - Satodime reading")
        let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
        let parser = SatocardParser()
        
        do {
            print("START SELECT")
            try cmdSet.select().checkOK()
            print("START GETSTATUS")
            let statusApdu = try cmdSet.cardGetStatus()
            print("START STATUS")
            cardStatus = try CardStatus(rapdu: statusApdu)
            print("Status: \(cardStatus)")
            logArrayTmp.append("Status: \(cardStatus)")
            // check if setupDone
            if cardStatus?.setupDone == false && self.promptForTransfer == true {
                isOwner = false
                // redirect to
                session?.stop(alertMessage: String(localized: "Satodime needs setup!"))
                print("Satodime needs setup!")
                // dispatchGroup is used to wait for scan() to finish before fetching web api
                dispatchGroup.leave()
                // initiate tranfer process
                operationType = "Accept"
                operationRequested = true
                return
            }
            // check Card authenticity
            do {
                (certificateCode, certificateDic) = try cmdSet.cardVerifyAuthenticity()
            } catch {
                print("Failed to authenticate card with error: \(error)")
                // show something
            }
            // get authentikey
            (_, authentikey, authentikeyHex) = try cmdSet.cardGetAuthentikey()
            print("Authentikey: \(authentikey)")
            print("AuthentikeyHex: \(authentikeyHex)")
            logArrayTmp.append("AuthentikeyHex: \(authentikeyHex)")
            var satodimeStatus = try SatodimeStatus(rapdu: cmdSet.satodimeGetStatus().checkOK())
            print("satodimeStatus: \(satodimeStatus)")
            //logArrayTmp.append("satodimeStatus: \(satodimeStatus)")
            // check for ownership
            if let unlockSecret = unlockSecretDict[authentikeyHex]{
                satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                isOwner = true
                print("Found an unlockSecret for this card: \(unlockSecret)")
            } else {
                isOwner = false
                print("Found no unlockSecret for this card!")
            }
            let nbKeys = satodimeStatus.maxNumKeys
            print("nbKeys: \(nbKeys)")
            let satodimeKeysState = satodimeStatus.satodimeKeysState
            print("satodimeKeysState: \(satodimeKeysState)")
            //vaultArray.reserveCapacity(nbKeys)
            DispatchQueue.main.async {   // <====
                // clear vaultArray before populating it
                self.vaultArray.removeAll()
                self.vaultArray.reserveCapacity(nbKeys)
                // updates logs
                self.syncLogs()
            }
            for index in 0 ..< nbKeys {
                print("index: \(index)")
                
                let satodimeKeyslotStatus = try SatodimeKeyslotStatus(rapdu: cmdSet.satodimeGetKeyslotStatus(keyNbr: UInt8(index)).checkOK())
                print("keyslotStatus: \(satodimeKeyslotStatus)")
                
                let pubkey: [UInt8]
                if satodimeKeysState[index] == 0x00 { // uninitialized
                    pubkey = [UInt8]()
                } else {
                    pubkey = try parser.parseSatodimeGetPubkey(rapdu: cmdSet.satodimeGetPubkey(keyNbr: UInt8(index)))
                }
                print("pubkey: \(pubkey)")
                
                var vaultItem = VaultItem(index: UInt8(index), keyslotStatus: satodimeKeyslotStatus)
                vaultItem.pubkey = pubkey
                vaultItem.address = try vaultItem.coin.pubToAddress(pubkey: pubkey)
                print("address: \(vaultItem.address)")
                
                // apppend vaultItem to array
                DispatchQueue.main.async {   // <====
                  self.vaultArray.append(vaultItem)
                }
                print("End for index: \(index)")
                
            }// end for index
            
            //print("DEBUG vaultArray:  \(vaultArray)")
        } catch let error {
            print("An error occurred: \(error.localizedDescription)")
            session?.stop(errorMessage: String(localized: "There was an issue while listing vaults: \(error.localizedDescription)"))
        }
        
        session?.stop(alertMessage: String(localized: "Listed vaults successfully!"))
        dispatchGroup.leave()
        print("DEBUG SATODIME - this is the end!")
        
    } // end onConnection
    
    func onConnectionForAction(cardChannel: CardChannel) -> Void {
        print("START - Satodime onConnectionForAction \(actionParams.action)")
        let cmdSet = SatocardCommandSet(cardChannel: cardChannel)
        let parser = SatocardParser()
        
        do {
            print("START SELECT")
            try cmdSet.select().checkOK()
            print("START GETSTATUS")
            let statusApdu = try cmdSet.cardGetStatus()
            print("Status: \(cmdSet.cardStatus)")
            if actionParams.action == "accept"{
                // check if setupDone
                if cmdSet.cardStatus?.setupDone == false {
                    // perform setup
                    do {
                        //_ = try cmdSet.cardSetup(pin_tries0: 5, pin0: pin0).checkOK()
                        _ = try cmdSet.satodimeCardSetup().checkOK()
                        let (_, authentikey, authentikeyHex) = try cmdSet.cardGetAuthentikey()
                        print("Authentikey: \(authentikey)")
                        print("AuthentikeyHex: \(authentikeyHex)")
                        // save in defaults
                        unlockSecretDict[authentikeyHex] = cmdSet.satodimeStatus.unlockSecret
                        defaults.set(unlockSecretDict, forKey: "unlockSecretDict")
                        isOwner = true
                        sessionForAction?.stop(alertMessage: String(localized: "Card ownership accepted successfully!"))
                        return
                    } catch {
                        print("Error during card setup: \(error)")
                        sessionForAction?.stop(errorMessage: String(localized: "Failed to accept card ownership with error: \(error.localizedDescription)"))
                        return
                    }
                } else {
                    print("Card transer already done!")
                    sessionForAction?.stop(alertMessage: String(localized: "Card transfer already done!"))
                    return
                }
            } // if accept
            
            let (_, authentikey, authentikeyHex) = try cmdSet.cardGetAuthentikey()
            print("AuthentikeyHex: \(authentikeyHex)")
            // check authentikey did not change between sessions (i.e. it's the same card)
            if self.authentikeyHex != authentikeyHex {
                print("Card mismatch! \nIs this the correct card?")
                sessionForAction?.stop(errorMessage: String(localized: "Card mismatch! \nIs this the correct card?"))
                return
            }
            _ = try cmdSet.satodimeGetStatus().checkOK()
            print("satodimeStatus: \(cmdSet.satodimeStatus)")
            // check for ownership
            if let unlockSecret = unlockSecretDict[authentikeyHex]{
                cmdSet.satodimeStatus.setUnlockSecret(unlockSecret: unlockSecret)
                print("Found an unlockSecret for this card: \(unlockSecret)")
            } else {
                print("Found no unlockSecret for this card!")
            }
            let nbKeys = cmdSet.satodimeStatus.maxNumKeys
            print("nbKeys: \(nbKeys)")
            // todo check indexReset < nbkeys
            
            //perform action!
            if actionParams.action == "seal" {
                do {
                    let rapdu = try cmdSet.satodimeSealKey(keyNbr: actionParams.index, entropyUser: actionParams.entropyBytes).checkOK()
                    print("SealSlot rapdu: \(rapdu)")
                    let rapdu2 = try cmdSet.satodimeSetKeyslotStatusPart0(keyNbr: actionParams.index, RFU1: 0x00, RFU2: 0x00, keyAsset: actionParams.getAssetByte(), keySlip44: actionParams.getSlip44(), keyContract: actionParams.contractBytes, keyTokenid: actionParams.tokenidBytes).checkOK()
                    print("setKeyslotStatus rapdu: \(rapdu)")
                    // partially update status
                    let pubkey = try parser.parseSatodimeGetPubkey(rapdu: rapdu)
                    // todo: get Coin()
                    DispatchQueue.main.async {
                        self.vaultArray[Int(self.actionParams.index)].pubkey = pubkey
                        self.vaultArray[Int(self.actionParams.index)].keyslotStatus.asset = self.actionParams.getAssetByte()
                        self.vaultArray[Int(self.actionParams.index)].keyslotStatus.status = 0x01
                        self.needsRefresh = true
                    }
                    sessionForAction?.stop(alertMessage: String(localized: "Vault sealed successfully!"))
                    return
                } catch {
                    print("SealSlot error: \(error)")
                    sessionForAction?.stop(errorMessage: String(localized: "Failed to seal vault with error: \(error.localizedDescription)"))
                    return
                }
            }
            else if actionParams.action == "unseal" {
                do {
                    let rapdu = try cmdSet.satodimeUnsealKey(keyNbr: actionParams.index).checkOK()
                    print("UnsealSlot rapdu: \(rapdu)")
                    // update status
                    DispatchQueue.main.async {
                        self.vaultArray[Int(self.actionParams.index)].keyslotStatus.status = 0x02
                    }
                    sessionForAction?.stop(alertMessage: String(localized: "Vault unsealed successfully!"))
                    return
                } catch {
                    print("UnsealSlot error: \(error)")
                    sessionForAction?.stop(errorMessage: String(localized: "Failed to unseal vault with error: \(error.localizedDescription)"))
                    return
                }
            }
            else if actionParams.action == "reset" {
                do {
                    let rapdu = try cmdSet.satodimeResetKey(keyNbr: actionParams.index).checkOK()
                    print("ResetSlot rapdu: \(rapdu)")
                    // update corresponding vaultItem
                    let satodimeKeyslotStatus = try SatodimeKeyslotStatus(rapdu: cmdSet.satodimeGetKeyslotStatus(keyNbr: actionParams.index).checkOK())
                    print("keyslotStatus after reset: \(satodimeKeyslotStatus)")
                    // todo: hardcode (unitialized) rapdu?
                    let pubkey = [UInt8]()
                    var vaultItem = VaultItem(index: actionParams.index, keyslotStatus: satodimeKeyslotStatus)
                    vaultItem.pubkey = [UInt8]()
                    vaultItem.address = try vaultItem.coin.pubToAddress(pubkey: pubkey)
                    print("address: \(vaultItem.address)")
                    DispatchQueue.main.async {
                        self.vaultArray[Int(self.actionParams.index)] = vaultItem
                    }
                    sessionForAction?.stop(alertMessage: String(localized: "Vault reset successfully!"))
                    return
                } catch {
                    print("ResetSlot error: \(error)")
                    sessionForAction?.stop(errorMessage: String(localized: "Failed to reset vault slot with error: \(error.localizedDescription)"))
                    return
                }
            }
            else if actionParams.action == "private"{
                do {
                    let rapdu = try cmdSet.satodimeGetPrivkey(keyNbr: actionParams.index).checkOK()
                    let privkeyInfo = try parser.parseSatodimeGetPrivkey(rapdu: rapdu)
                    // update status
                    DispatchQueue.main.async {
                        self.vaultArray[Int(self.actionParams.index)].privkey = privkeyInfo.privkey
                        self.vaultArray[Int(self.actionParams.index)].entropy = privkeyInfo.entropy
                        // todo: remove
                        //print("privkey: \(self.vaultArray[Int(self.actionParams.index)].privkey)")
                        //print("entropy: \(self.vaultArray[Int(self.actionParams.index)].entropy)")
                    }
                    sessionForAction?.stop(alertMessage: String(localized: "Vault privkey recovered successfully!"))
                    return
                } catch {
                    print("GetPrivkey error: \(error)")
                    sessionForAction?.stop(errorMessage: String(localized: "Failed to get vault private key with error: \(error.localizedDescription)"))
                    return
                }
            }
            else if actionParams.action == "transfer"{
                do {
                    let rapdu = try cmdSet.satodimeInitiateOwnershipTransfer().checkOK()
                    print("TransferCard rapdu: \(rapdu)")
                    isOwner = false
                    sessionForAction?.stop(alertMessage: String(localized: "Ownership transfer initiated successfully!"))
                    return
                } catch {
                    print("TransferCard error: \(error)")
                    sessionForAction?.stop(errorMessage: String(localized: "Failed to transfer ownership with error: \(error.localizedDescription)"))
                    return
                }
            } else {
                // should never happen?
                print("Unknown operation requested: \(actionParams.action)")
                sessionForAction?.stop(alertMessage: String(localized: "Satodime disconnected"))
                print("DEBUG SATODIME - this is the end!")
            }
            
        } catch let error {
            print("An error occurred: \(error.localizedDescription)")
            sessionForAction?.stop(errorMessage: String(localized: "An error occured: \(error.localizedDescription)"))
            return
        }
        
    } // end onConnectionForAction
    
    func onDisconnection(error: Error) {
        print("DEBUG SATODIME - onDisconnection")
        print("Connection interrupted due to error: \(error)")
    }
    
    //
    // WEB APIs
    //
    
    func fetchDataFromWeb() async -> [VaultItem] {
        print("in fetchDataFromWeb START")
        logArrayTmp.append("ApiKeys count: \(VaultItem.apiKeys.count)")
        //logArrayTmp.append("ApiKeys: \(VaultItem.apiKeys)") // TODO: remove
        let nbKeys = vaultArray.count
        print("in fetchDataFromWeb nbKeys: \(nbKeys)")
        var coinInfoArray = [VaultItem]()
        coinInfoArray.reserveCapacity(nbKeys)
        for index in 0 ..< nbKeys {

            print("Start task index: \(index)")
            var coinInfo = vaultArray[index]
            
            // fetch balance
            print("fetching balance...")
            do {
                print ("address: \(coinInfo.address)")
                coinInfo.balance = try await coinInfo.coin.getBalance(addr: coinInfo.address)
                print ("balance: \(coinInfo.balance)")
                coinInfo.addressUrl = URL(string: coinInfo.coin.getAddressWebLink(address: coinInfo.address) ?? "")
                print ("addressUrl: \(coinInfo.addressUrl)")
            } catch {
                coinInfo.balance = nil
                print("Request failed with error: \(error)")
                print("Coin: \(coinInfo.coin.coinSymbol)")
                //logArrayTmp.append("Coin: \(coinInfo.coin.coinSymbol)")
                logArrayTmp.append("#\(index): balance request error: \(error)")
            }
            
            // fetch exchange rate
            do {
                coinInfo.exchangeRate = try await coinInfo.coin.getExchangeRateBetween(otherCoin: selectedCurrency)
                coinInfo.otherCoinSymbol = selectedCurrency
                print ("exchangeRate: \(coinInfo.exchangeRate) \(coinInfo.otherCoinSymbol)")
            } catch {
                coinInfo.exchangeRate = nil
                coinInfo.otherCoinSymbol = selectedCurrency
                print ("Failed to get exchange rate with error: \(error)")
                logArrayTmp.append("#\(index): exchange rate error: \(error)")
            }
        
            // for tokens (including NFTs)
            do {
                if coinInfo.isToken() {
                    let contractString = coinInfo.coin.contractBytesToString(contractBytes: coinInfo.keyslotStatus.contract)
                    print ("contractString: \(contractString)")
                    coinInfo.tokenBalance = try await coinInfo.coin.getTokenBalance(addr: coinInfo.address, contract: contractString)
                    print("tokenBalance: \(coinInfo.tokenBalance)")
                    coinInfo.tokenInfo = try await coinInfo.coin.getTokenInfo(contract: contractString)
                    coinInfo.tokenExchangeRate = try await coinInfo.coin.getTokenExchangeRateBetween(contract: contractString, otherCoin: selectedCurrency)
                    print("tokenExchangeRate: \(coinInfo.tokenExchangeRate)")
                    coinInfo.tokenUrl = URL(string: coinInfo.coin.getTokenWebLink(contract: contractString) ?? "")
                    print ("tokenUrl: \(coinInfo.tokenUrl)")
                }
            } catch {
                coinInfo.tokenExchangeRate = nil
                print("Token Request failed with error: \(error)")
                logArrayTmp.append("#\(index): token error: \(error)")
            }

            // for NFT
            do {
                if coinInfo.isNft() {
                    let contractString = coinInfo.coin.contractBytesToString(contractBytes: coinInfo.keyslotStatus.contract)
                    let tokenidString = coinInfo.coin.tokenidBytesToString(tokenidBytes: coinInfo.keyslotStatus.tokenid)
                    print ("tokenidString: \(tokenidString)")
                    coinInfo.nftInfo = try await coinInfo.coin.getNftInfo(contract: contractString, tokenid: tokenidString)
                    print ("nftInfo: \(coinInfo.nftInfo)")
                    logArrayTmp.append("#\(index): nftInfo: \(coinInfo.nftInfo)")
                    coinInfo.nftUrl = URL(string: coinInfo.coin.getNftWebLink(contract: contractString, tokenid: tokenidString) ?? "")
                    print ("nftUrl: \(coinInfo.nftUrl)")
                }
            } catch {
                print("NFT Request failed with error: \(error)")
                logArrayTmp.append("#\(index): NFT error: \(error)")
            }

            coinInfoArray.append(coinInfo)
            print("End for async index: \(index)")
        }// end for async
        return coinInfoArray
    }
    
    @MainActor
    func executeQuery() async {
        print("in executeQuery START")
        dispatchGroup.enter()
        self.scan()
        dispatchGroup.notify(queue: DispatchQueue.global()){
            Task {
                self.vaultArray = await self.fetchDataFromWeb()
                self.syncLogs()
            }
        }
    }
    
    func syncLogs() {
        self.logArray.append(contentsOf: self.logArrayTmp)
        self.logArrayTmp.removeAll()
    }
    
}
