//
//  Autocomplete.swift
//  Autocomplete based on https://github.com/dmytro-anokhin/Autocomplete
//

import Combine
import Foundation

@MainActor
final class ContractsAutocompleteObject: ObservableObject {

    let delay: TimeInterval = 0.3

    @Published var suggestions: [ContractTuple] = []

    private let contractsCache: ContractsCache // = ContractsCache(source: CitiesFile()!)

    private var task: Task<Void, Never>?

    init() {
        print("ContractAutoCompleteObject init()")
        contractsCache = ContractsCache(source: ContractsFile())
    }
    
    func autocomplete(_ text: String, blockchain: String, asset: String) {
        guard !text.isEmpty else {
            suggestions = []
            task?.cancel()
            return
        }

        task?.cancel()

        task = Task {
            await Task.sleep(UInt64(delay * 1_000_000_000.0))

            guard !Task.isCancelled else {
                return
            }

            let newSuggestions = await contractsCache.lookup(prefix: text, blockchain: blockchain, asset: asset)

            if isSingleSuggestion(suggestions, equalTo: text) {
                // Do not offer only one suggestion same as the input
                suggestions = []
            } else {
                suggestions = newSuggestions
            }
        }
    }

    private func isSingleSuggestion(_ suggestions: [ContractTuple], equalTo text: String) -> Bool {
        guard let suggestion = suggestions.first, suggestions.count == 1 else {
            return false
        }

        return suggestion.label.lowercased() == text.lowercased()
    }
}
