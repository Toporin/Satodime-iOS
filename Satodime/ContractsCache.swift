////
////  ContractsCache.swift
////
//
///// The source of all contracts names
//protocol ContractsSource {
//    func loadContracts(blockchain: String, asset: String) -> [ContractTuple]
//}
//
///// The `ContractsCache` object manages the list of contracts names loaded from an external source.
//actor ContractsCache {
//
//    /// Source to load city names.
//    let source: ContractsSource
//
//    //private var cachedContracts: [ContractTuple]?
//    private var cachedContractsDict: [String:[ContractTuple]] = [:]
//    
//    init(source: ContractsSource) {
//        self.source = source
//    }
//
//    /// The list of contracts names.
//    func getContracts(blockchain: String, asset: String) -> [ContractTuple] {
//        let res = "contract_" + blockchain + "_" + asset
//        if let contracts = cachedContractsDict[res] {
//            return contracts
//        }
//
//        let contracts = source.loadContracts(blockchain: blockchain, asset: asset)
//        cachedContractsDict[res] = contracts
//
//        return contracts
//    }
//
//}
//
//extension ContractsCache {
//    /// Returns a list of contract names filtered using given prefix.
//    func lookup(prefix: String, blockchain: String, asset: String) -> [ContractTuple] {
//        getContracts(blockchain: blockchain, asset: asset).filter({ $0.label.range(of: prefix, options:.caseInsensitive) != nil }) // ignorecase
//    }
//}
//
