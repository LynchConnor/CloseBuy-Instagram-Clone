//
//  CreateProfileView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 15/09/2021.
//

import SwiftUI
import Combine

enum UsernameCheck: Error {
    case invalid
    case alreadyExists
    case valid
}

extension CreateProfileView {
    class ViewModel: ObservableObject {
        
        @Published var isActive: Bool = false
        
        @Published var inputImage: UIImage?
        @Published var image: Image?
        
        @Published var username: String = ""
        @Published var displayName: String = ""
        
        @Published var canContinue: Bool = false
        
        private var cancellables = Set<AnyCancellable>()
        
        func uploadData(){
            guard let id = AuthViewModel.shared.currentState?.uid else { return }
            
            guard let inputImage = inputImage else { return }
            
            ImageUploader.uploadImage(image: inputImage, path: .icon) { url in
                
                let data: [String: Any] = [
                    "username": self.username,
                    "displayName": self.displayName,
                    "profileIconURL": url
                ]
                
                COLLECTION_USERS.document(id).setData(["profile": data])
                AuthViewModel.shared.validateAuthState()
            }
            
            //When the user creates an account, their username, displayname and profilePicture are stored within the database
        }
        
    }
}

struct CreateProfileView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel: ViewModel = .init()
    
    private func loadImage(){
        viewModel.image = Image(uiImage: viewModel.inputImage!)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            
            Text("LET’S SETUP YOUR PERSONAL PROFILE")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.system(size: 22, weight: .bold))
                .lineSpacing(5)
                .padding(.vertical, 15)
            
            ZStack {
                
                if let image = viewModel.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .overlay(
                            
                            Button {
                                viewModel.isActive.toggle()
                            } label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .foregroundColor(.black)
                                    .scaledToFill()
                                    .frame(width: 15, height: 15)
                                    .padding(10)
                                    .background(Color.white)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                    .clipShape(Circle())
                                    .offset(y: 2)
                            }
                            ,alignment: .bottomTrailing
                        )
                }else{
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.init(red: 247/255, green: 247/255, blue: 247/255))
                            .frame(maxWidth: .infinity)
                            .frame(height: 125)
                            .cornerRadius(10)
                        VStack {
                            Image("smiley.face")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                            Text("Add a profile picture")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(Color.init(red: 193/255, green: 193/255, blue: 193/255))
                    }
                    .onTapGesture {
                        viewModel.isActive.toggle()
                    }
                }
                
            }
            .sheet(isPresented: $viewModel.isActive) {
                if viewModel.inputImage != nil {
                    loadImage()
                }
            } content: {
                ImagePicker(image: $viewModel.inputImage)
            }
            
            VStack(spacing: 35) {
                
                CustomProfileTextField(binding: $viewModel.username, placeholder: "Username")
                
                CustomProfileTextField(binding: $viewModel.displayName, placeholder: "Display name")
                
            }
            .padding(.bottom, 25)
            .padding(.top, 10)
            
            Button {
                viewModel.uploadData()
            } label: {
                Text("Create account".uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.init(red: 240/255, green: 164/255, blue: 62/255))
            .cornerRadius(15)
            .padding(.horizontal, 25)
            
            
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 25, trailing: 0))
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 20)
        .navigationBarHidden(true)
        .navigationBarTitle("")
    }
}

struct CustomProfileTextField: View {
    
    @Binding var binding: String
    let placeholder: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            if !isSecure {
                TextField("", text: $binding)
            }
            else{
                SecureField("", text: $binding)
            }
            
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color.gray)
        }
    }
}

struct CreateProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateProfileView()
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
    }
}
