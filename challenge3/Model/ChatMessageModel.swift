//
//  ChatMessageModel.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/10/25.
//

import Foundation
struct ChatMessage: Codable, Identifiable {
    var id: UUID = UUID()
    var role: Role
    var content: String
    var isPartial: Bool 
    
    enum Role: String, Codable {
        case user
        case assistant
    }
}
