//
//  MainMessagesView.swift
//  betterChat
//
//  Created by Artem on 10/01/2023.
//

import SwiftUI
import Firebase
import FirebaseStorage


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
