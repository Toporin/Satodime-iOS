//
//  UnlockCodeDialog.swift
//  Satodime
//
//  Created by Satochip on 19/09/2025.
//


import SwiftUI

struct UnlockCodeDialog: View {
    @Binding var isPresented: Bool
    @State private var unlockCode: String = ""
    
    let title: String
    let message: String
    let onEnter: (String) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss when tapping outside
                    isPresented = false
                    onCancel()
                }
            
            // Dialog content
            VStack(spacing: 20) {
                // Title
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                // Message text
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                // Input field
                VStack(alignment: .leading, spacing: 8) {
//                    Text("Enter Code")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
                    
                    TextField("CVC", text: $unlockCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .keyboardType(.asciiCapable)
                        .onReceive(unlockCode.publisher.collect()) {
                            // Filter to only allow alphanumeric characters and convert to uppercase
                            let filtered = String($0.compactMap { char in
                                char.isLetter || char.isNumber ? char.uppercased().first : nil
                            })
                            if filtered != unlockCode {
                                unlockCode = filtered
                            }
                        }
                }
                .padding(.horizontal, 4)
                
                // Buttons
                HStack(spacing: 12) {
                    // Cancel button
                    Button("Cancel") {
                        isPresented = false
                        onCancel()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                    
                    // Enter button
                    Button("Enter") {
                        isPresented = false
                        onEnter(unlockCode)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(unlockCode.isEmpty ? Color(.systemGray4) : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(unlockCode.isEmpty)
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 8)
            .padding(.horizontal, 40)
        }
        .onAppear {
            unlockCode = ""
        }
    }
}

struct UnlockCodeDialog_Previews: PreviewProvider {
    static var previews: some View {
        UnlockCodeDialog(
            isPresented: .constant(true),
            title: "Enter CVC Code",
            message: "Please enter your CVC code to continue",
            onEnter: { code in
                print("Entered code: \(code)")
            },
            onCancel: {
                print("Cancelled")
            }
        )
    }
}
