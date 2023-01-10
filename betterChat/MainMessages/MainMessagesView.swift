//
//  MainMessagesView.swift
//  betterChat
//
//  Created by Artem on 10/01/2023.
//

import SwiftUI





class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isCurrenltyLoggedOut = false
    
    

    init(){
        
        DispatchQueue.main.async {
            self.isCurrenltyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
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
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView {
            //custom nav bar
            VStack{
//                Text(" User: \(vm.chatUser?.uid ?? "")")
             customNavBar
             messagesView
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
//                        .default(Text("Default Button")),
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
    

    
    private var newMessageButton: some View {
        Button {
            
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
        }
    }
    
    private var messagesView: some View {
        ScrollView{
            ForEach(0..<10, id:\.self) {num in
                VStack{
                    HStack(spacing: 16){

                           
                        
                      Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1))
                        
                        VStack(alignment: .leading){
                            Text("Username")
                                .font(.system(size: 16, weight: .bold))
                            Text("Message sent to user")
                                .font(.system(size: 14))
                                .foregroundColor(Color(.lightGray))
                        }
                        Spacer()
                        Text("22d")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
            
            }.padding(.bottom, 50)
           
        }
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()

    }
}
