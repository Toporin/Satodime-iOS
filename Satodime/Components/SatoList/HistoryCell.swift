//
//  HistoryCell.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//

import SwiftUI

struct HistoryCellModel: Identifiable {
    let id = UUID()
    let event: String
    let date: String
    let detail: String
    let status: String
}

struct HistoryCell: View {
    // MARK: - Properties
    let historyItem: HistoryCellModel

    var body: some View {
        HStack {
            Image(systemName: "clock.arrow.circlepath")
                .resizable()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(historyItem.event)
                    .font(.headline)
                Text(historyItem.date)
                    .font(.subheadline)
            }
            .padding(.leading, 10)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(historyItem.detail)
                    .font(.headline)
                Text(historyItem.status)
                    .font(.subheadline)
            }
            .padding(.trailing, 10)
        }
        .background(Constants.Colors.satoListBackground)
    }
}
