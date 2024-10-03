//
//  User.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//

import Foundation


struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let name: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, email, name
        case createdAt = "createdAt"  // Changed to match server response
        case updatedAt = "updatedAt"  // Changed to match server response
    }
}

struct AuthResponse: Codable {
    let success: Bool
    let token: String
    let user: User
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case success, token, user, message
    }
}
