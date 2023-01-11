//
//  NewMessage.swift
//  betterChat
//
//  Created by Artem on 10/01/2023.
//

import SwiftUI


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

struct NewMessage: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    let didSelectNewUser: (ChatUser) -> ()
    
    
    var body: some View {
        NavigationView{
            ScrollView{
                Text(vm.errorMessage)
                ForEach(vm.users){ user in
                    Button{
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    }label: {
                        HStack(spacing: 16){
                            AsyncImage(url: URL(string: user.profileImageUrl ?? ""))
                            { image in image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color(.label), lineWidth: 1))
                            }
                                placeholder: { Color.blue }
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color(.label), lineWidth: 1))
                            
                            Text(user.email)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }.padding(.horizontal)
                   
                    }
                    Divider()
                        .padding(.vertical, 8)
                  
                }
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    }label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

struct NewMessage_Previews: PreviewProvider {
    static var previews: some View {
        NewMessage(didSelectNewUser: {user in 
            
        })
    }
}
