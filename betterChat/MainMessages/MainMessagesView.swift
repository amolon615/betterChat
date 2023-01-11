//
//  MainMessagesView.swift
//  betterChat
//
//  Created by Artem on 10/01/2023.
//

import SwiftUI
import Firebase
import FirebaseStorage


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



struct MainMessagesView: View {
    @State var showLogout = false
    @State var shouldNavigateToChatLogView = false
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView {
            VStack{
             customNavBar
             messagesView
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
                
            }.overlay(
            newMessageButton, alignment: .bottom
            )
            .navigationBarHidden(true)
        }
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16){
            AsyncImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
            { image in image
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1))
            }
                placeholder: { Color.blue }
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1))

            
            VStack(alignment: .leading, spacing: 4) {
                let email = vm.chatUser?.email.replacingOccurrences(of: "@grvnk.com", with: "") ?? ""
                
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                
                HStack{
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
              
            }
            Spacer()
            Button {
                showLogout.toggle()
            }label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
          
        }
        .padding()
        .actionSheet(isPresented: $showLogout) {
            .init(title: Text("Seetings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign out"), action: {
                    print("sign out")
                    vm.handleSignout()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isCurrenltyLoggedOut) {
            LoginView(didCompleteLoginProcess: {
                withAnimation(.spring()){
                    self.vm.isCurrenltyLoggedOut = false
                    vm.fetchCurrentUser()
                }
                
                
            })
        }
    }
    

    

    
    
    
    private var messagesView: some View {
        
        ScrollView{
            ForEach(vm.recentMessages) {recentMessage in
                VStack{
                    NavigationLink {
                        Text("Destinaton")
                    } label: {
                        HStack(spacing: 16){
                            AsyncImage(url: URL(string: recentMessage.profileImageUrl ?? ""))
                            { image in image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color(.label), lineWidth: 1))
                            }
                                placeholder: { Color.blue }
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color(.label), lineWidth: 1))
                  
                            
                            
                            VStack(alignment: .leading, spacing: 8){
                                Text(recentMessage.email)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(.label))
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.darkGray))
                                    .multilineTextAlignment(.leading)
                                
                            }
                            Spacer()
                            Text("22d")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }

                    
                  
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
            
            }.padding(.bottom, 50)
           
        }
    }
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View {
        
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack{
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
            .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
                NewMessage(didSelectNewUser: { user in
                    print(user.email)
                    self.shouldNavigateToChatLogView.toggle()
                    self.chatUser = user
                       
                })
            }
            
        }

    }
    @State var chatUser: ChatUser?
}



struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()

    }
}
