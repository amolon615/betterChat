//
//  RecentMessage.swift
//  betterChat
//
//  Created by Artem on 11/01/2023.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseStorage
import Firebase

struct RecentMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
       let text, email: String
       let fromId, toId: String
       let profileImageUrl: String
       let timestamp: Timestamp
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}
