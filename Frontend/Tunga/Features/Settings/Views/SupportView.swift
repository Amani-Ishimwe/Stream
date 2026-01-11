import SwiftUI

struct SupportView: View {
    var body: some View {
        List {
            Section("Contact") {
                Label("support@swiftpayplus.com", systemImage: "envelope.fill")
                Label("+1 (800) 555-0101", systemImage: "phone.fill")
            }
            
            Section("Helpful Links") {
                Label("Report an Issue", systemImage: "exclamationmark.bubble.fill")
                Label("Status Page", systemImage: "wifi")
            }
        }
        .navigationTitle("Support")
    }
}
//
//  SupportView.swift
//  Tunga
//
//  Created by Amani on 12/12/25.
//

