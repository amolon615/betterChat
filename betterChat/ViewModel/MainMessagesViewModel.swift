//
//  MainMessagesViewModel.swift
//  betterChat
//
//  Created by Artem on 11/01/2023.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorage



class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isCurrenltyLoggedOut = false
    @Published var recentMessages = [RecentMessage]()
    
    

    init(){
        
        DispatchQueue.main.async {
            self.isCurrenltyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        
        fetchRecentMessages()
        
    }
    
    private func fetchRecentMessages() {
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
            
            FirebaseManager.shared.firestore
                .collection("recent_messages")
                .document(uid)
                .collection("messages")
                .order(by: "timestamp")
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        self.errorMessage = "Failed to listen for recent messages: \(error)"
                        print(error)
                        return
                    }
                    
                    querySnapshot?.documentChanges.forEach({ change in
                        let docId = change.document.documentID
                        
                        if let index = self.recentMessages.firstIndex(where: { rm in
                            return rm.documentId == docId
                        }) {
                            self.recentMessages.remove(at: index)
                        }
                        
                        self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
                        
                        
    //                    self.recentMessages.append()
                    })
                }
        }
    
    
     func fetchCurrentUser() {
        
        guard let uid =
                FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid."
            
            return
        }
        
        
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).getDocument {snapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch current user : \(error)"
                    print("Failed to fetch current user:", error)
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                
                self.chatUser = .init(data: data)
                
                
            }
    }
    
     func handleSignout(){
         self.isCurrenltyLoggedOut.toggle()
         do{
             try FirebaseManager.shared.auth.signOut()
         } catch let error {
             print("failed signout \(error.localizedDescription)")
         }
        
    }
    
    
}
