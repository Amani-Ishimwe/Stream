import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var phone: String
    
    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        phone: String
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
    }
}
//
//  User.swift
//  Tunga
//
//  Created by Amani on 12/12/25.
//

