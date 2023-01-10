//
//  ContentView.swift
//  betterChat
//
//  Created by Artem on 10/01/2023.
//

import SwiftUI



struct LoginView: View {
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    @State var loginStatusMessage = ""
    
    @State var showImagePicker = false
    @State var image: UIImage?
    
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack (spacing: 16){
                    Picker(selection: $isLoginMode, label:
                            Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create account")
                            .tag(false)
                    }.pickerStyle(.segmented).padding()
                    
                    if !isLoginMode {
                        Button{
                            showImagePicker = true
                        } label: {
                            
                            VStack{
                                if let image = image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 64, height: 64)
                                        .clipShape(Circle())
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                                
                            }.overlay(Circle().stroke(Color.black, lineWidth: 3))
                            
                            
                        }
                        
                    }
                    
                    Group{
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                        SecureField("Password", text: $password)
                    } .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(.white)
                    
                    
                    
                    Button{
                        handleAction()
                    } label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Log in" : "Create account")
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(.blue)
                    }
                    
                    Text(loginStatusMessage)
                        .foregroundColor(.red)
                    
                }.padding()
                
                
                
            }
            .navigationTitle(isLoginMode ? "Log in" : "Create account")
            .background(Color.gray.opacity(0.1).ignoresSafeArea())
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(image: $image)
        }
    }
    
    
    private func handleAction(){
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser(){
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){
            result, err in
            if let err = err {
                loginStatusMessage = "Faile to log in user \(err)"
                print(loginStatusMessage)
                return
            }
            loginStatusMessage = "user logged in as \(result?.user.uid ?? "no user id")"
            print(loginStatusMessage)
        }
    }
    
    private func createNewAccount(){
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, error in
            if let error = error {
                loginStatusMessage = "Failed to create user \(error)"
                print(loginStatusMessage)
                return
            }
            loginStatusMessage = "user created \(result?.user.uid ?? "no user id")"
            print(loginStatusMessage)
            
            persistImageToStorage()
        }
    }
    
    func persistImageToStorage(){
        let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData,metadata: nil) { metadata, error in
            if let error = error {
                self.loginStatusMessage = "Failed to push image to Storage \(error)"
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    self.loginStatusMessage = "Failed to retreive download URL \(error)"
                    return
                }
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email" : self.email, "uid": uid, "profileImageUrl" : imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { error in
                if let error = error {
                    print (error)
                    self.loginStatusMessage = "\(error)"
                    return
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
