//
//  FirebaseManager.swift
//  betterChat
//
//  Created by Artem on 10/01/2023.
//

import Foundation
import Firebase
import FirebaseStorage



class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
 
    
    override init(){
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
}

