//
//  UnknownAction.swift
//  Satodime for iOS
//
//  Created by Satochip on 21/01/2023.
//  Copyright © 2023 Satochip S.R.L.
//

import SwiftUI

struct UnknownAction: View {
    let operation: String
    let index: UInt8
    
    var body: some View {
        Text("Ooops, unknown operation \(operation) at vault: \(Int64(index))!")
    }
}

struct UnknownAction_Previews: PreviewProvider {
    static var previews: some View {
        UnknownAction(operation: "preview", index: 0)
    }
}
