//
//  SatoChoiceSelector.swift
//  Satodime
//
//  Created by Lionel Delvaux on 16/10/2023.
//

import SwiftUI

protocol SelectableItem {
    var displayString: String { get }
}

struct SatoChoiceSelector<Item: SelectableItem & Hashable>: View {
    @Binding var selectedItem: Item
    var items: [Item]

    var body: some View {
        VStack(spacing: 24) {
            ForEach(items, id: \.self) { item in
                HStack {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                        .background(selectedItem == item ? Constants.Colors.ledGreen : .clear)
                        .clipShape(Circle())
                        .frame(width: 32, height: 32)
                    
                    Spacer()
                    
                    SatoText(text: item.displayString, style: .lightSubtitle)
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    selectedItem = item
                }
            }
        }
    }
}

