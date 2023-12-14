////
////  ContractsFile.swift
////  Autocomplete
////
////
//
//import Foundation
//
//struct ContractTuple: Hashable {
//    let label: String
//    let contract: String
//}
//
//struct ContractsFile: ContractsSource {
//
//    init() {
//    }
//
//    func loadContracts(blockchain: String, asset: String) -> [ContractTuple] {
//        do {
//            let res = "contracts_" + blockchain + "_" + asset
//            guard let location = Bundle.main.url(forResource: res, withExtension: nil) else {
//                //assertionFailure("{res} file is not in the main bundle")
//                print("{res} file is not in the main bundle")
//                return []
//            }
//            let data = try Data(contentsOf: location)
//            let string = String(data: data, encoding: .utf8)
//            let stringArray = string?.components(separatedBy: .newlines) ?? []
//            
//            var contracts: [ContractTuple] = []
//            for string in stringArray {
//                //print("string: \(string)")
//                // ignore lines starting with "//"
//                if string.hasPrefix("//"){
//                    continue
//                }
//                let tmpArray = string.components(separatedBy: ":")
//                if (tmpArray.count>=2){
//                    contracts += [ContractTuple(label: tmpArray[0], contract: tmpArray[1])]
//                }
//            }
//            //print("contracts: \(contracts)")
//            return contracts
//        }
//        catch {
//            print("Error while reading contracts file")
//            return []
//        }
//    }
//    
//}
//
