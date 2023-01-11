//
//  NewMessageViewModel.swift
//  betterChat
//
//  Created by Artem on 11/01/2023.
//


import Foundation
import SwiftUI
import Firebase
import FirebaseStorage

class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users: [ChatUser] = []
    @Published var errorMessage = ""
    
    init(){
        fetchAllusers()
    }
    
    private func fetchAllusers(){
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users \(error)"
                    print("Faiked to fetch users: \(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({snapshot in
                     let data =  snapshot.data()
                    let user = ChatUser(data: data)
                    //removing active session user from the list of chats
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(.init(data: data))
                    }
                })
            }
    }
}
