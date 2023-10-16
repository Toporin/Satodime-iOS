//
//  ShowLogs.swift
//  Satodime
//
//  Created by Satochip on 23/02/2023.
//

import SwiftUI

struct ShowLogs: View {
    
    var logArray: [String]
    
    var body: some View {
        
        ScrollView {
            Text("Logs")
                .font(.title)
            HStack {
                Text("Number of entries: \(logArray.count)")
                    .font(.headline)
                Image(systemName: "doc.on.doc")
                    .onTapGesture(count: 1) {
                        var txt=""
                        for item in logArray {
                            txt += item
                            txt += "\n\n---\n\n"
                        }
                        UIPasteboard.general.string = txt
                    }
            }
            Divider()
            VStack {
                ForEach(logArray, id: \.self) { item in
                    Text("\(item)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                }
            }
        }
    }
}

struct ShowLogs_Previews: PreviewProvider {
    static var previews: some View {
        ShowLogs(logArray: ["test", "test2"])
    }
}
