import SwiftUI

struct FAQsView: View {
    let faqs: [(question: String, answer: String)] = [
        ("Is SwiftPay+ secure?", "Yes, all traffic is secured and sensitive data is stored securely."),
        ("How do I reset my PIN?", "Go to Security settings and choose Change Transaction PIN."),
        ("What fees do you charge?", "Transfers are free in this demo. Add real fees when backend is ready.")
    ]
    
    var body: some View {
        List {
            ForEach(faqs, id: \.question) { item in
                DisclosureGroup(item.question) {
                    Text(item.answer)
                        .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("FAQs")
    }
}
//
//  FAQsView.swift
//  Tunga
//
//  Created by Amani on 12/12/25.
//

