//
//  ChatMessage.swift
//  betterChat
//
//  Created by Artem on 11/01/2023.
//

import Foundation
import Firebase
import FirebaseStorage

struct ChatMessage: Identifiable {
    var id: String { documentId }
    let documentId: String
    
    let fromId, toId, text, timestamp: String
   
    
    init(documentId: String, data: [String: Any]){
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
        self.timestamp = data[FirebaseConstants.timestamp] as? String ?? ""
    }
}
