//
//  ChatLogView.swift
//  betterChat
//
//  Created by Artem on 10/01/2023.
//

import SwiftUI
import Firebase
import  FirebaseFirestore




struct ChatLogView: View {
   
    
    let chatUser: ChatUser?

    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    @ObservedObject var vm: ChatLogViewModel
    
    static let emptyScrollToString = "Empty"
    
    
    
    var body: some View {
        ZStack{
            messagesView
            Text(vm.errorMessage)
            VStack(spacing: 0){
                Spacer()
                chatBottomBar
                    .background(Color.white.ignoresSafeArea())
            }
        }

        .navigationTitle(chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
     
        
        
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16){
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack{
                DescriptionPlaceholder()
                TextEditor(text:$vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }.frame(height: 40)
            Button {
                vm.handleSend()
            }label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.blue)
            .cornerRadius(8)
             
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var messagesView: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(vm.chatMessages) { message in
                            MessageView(message: message)
                                
                        }
                        
                        HStack{ Spacer() }.id(Self.emptyScrollToString)
                    
                    }
                    .onReceive(vm.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                            print("scroll attempted")
                        }
                    }
                  
                }
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
            .safeAreaInset(edge: .bottom) {
                chatBottomBar
                    .background(Color(.systemBackground).ignoresSafeArea())
            }
        }
    }
}

struct MessageView: View {
    let message: ChatMessage
    var body: some View {
        VStack{
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack{
                    Spacer()
                    HStack{
                        Text(message.text)
                            .foregroundColor(.white)
                        
                    }
                    .padding()
//                            .background(Color(message.toId == vm.currentUserId ? .blue :.red))
                    .background(Color.blue)
                    .cornerRadius(8)
                }
               
            } else {
                HStack{
                   
                    HStack{
                        Text(message.text)
                            .foregroundColor(.blue)
                        
                    }
                    .padding()
                    .background(Color(.white))
                    .cornerRadius(8)
                    Spacer()
                }
              
            }
        } .padding(.horizontal)
            .padding(.top, 8)
    }
}


private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ChatLogView(chatUser: .init(data: ["uid": "kQ1LBH9gqSgJozo44oQOg44Kjy72", "email": "artem10@grvnk.com"]))
        }
        MainMessagesView()
        
    }
}
