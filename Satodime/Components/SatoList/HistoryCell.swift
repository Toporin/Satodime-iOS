//
//  HistoryCell.swift
//  Satodime
//
//  Created by Lionel Delvaux on 12/10/2023.
//

import SwiftUI

struct HistoryCellViewModel: Identifiable {
    let id = UUID()
    let event: String
    let date: String
    let detail: String
    let status: String
}

struct HistoryCell: View {
    // MARK: - Properties
    let historyItem: HistoryCellViewModel

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                
                Image("ic_history_received")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            
            VStack(alignment: .leading) {
                SatoText(text: historyItem.event, style: .subtitleBold)
                    .font(.headline)
                SatoText(text: historyItem.date, style: .lightSubtitle)
                    .font(.subheadline)
            }
            .padding(.leading, 10)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                SatoText(text: historyItem.detail, style: .lightSubtitle)
                    .font(.headline)
                SatoText(text: historyItem.status, style: .lightSubtitle)
                    .font(.subheadline)
            }
            .padding(.trailing, 10)
        }
        .background(Constants.Colors.satoListBackground)
    }
}
