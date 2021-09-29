//
//  EditProfileView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 17/09/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct EditProfileView: View {
    
    @EnvironmentObject var viewModel: ProfileView.ViewModel
    
    @State var displayName: String = ""
    @State var bio: String = ""
    
    @State var containerHeight: CGFloat = 0
    
    @State var isProcessing: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    //MARK:- Profile Icon
    @State var editProfileImage: Bool = false
    @State var profileImage: UIImage?
    
    private func loadIcon() {
        guard let image = selectedImage else { return }
        self.profileImage = image
    }
    
    //MARK:- Profile Banner
    @State var editBannerImage: Bool = false
    @State var bannerImage: UIImage?
    
    private func loadBanner() {
        guard let image = selectedImage else { return }
        self.bannerImage = image
    }
    
    @State var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            
            //If the user has changed their banner, show updated image, otherwise their current banner. If no banner, show default
            
            ZStack(alignment: .bottom) {
                ZStack {
                    if let image = bannerImage {
                        Image(uiImage: image)
                            .resizable()
                    }else{
                        if let url = viewModel.user?.profile.bannerURL {
                            WebImage(url: URL(string: url))
                        }
                        else{
                            Rectangle()
                                .redacted(reason: .placeholder)
                        }
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .frame(minWidth: 0, maxWidth: .infinity)
                .clipped()
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(colors: [.black.opacity(0.75), .clear, .clear], startPoint: .top, endPoint: .bottom))
                )
                .overlay(
                    Button(action: {
                        editBannerImage.toggle()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                    })
                )
                .sheet(isPresented: $editBannerImage, onDismiss: {
                    loadBanner()
                }, content: {
                    ImagePicker(image: $selectedImage)
                })
                
                ZStack {
                    if let image = profileImage {
                        Image(uiImage: image).resizable()
                    }else{
                        if let url = viewModel.user?.profile.profileIconURL {
                            WebImage(url: URL(string: url))
                                .resizable()
                        }else{
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                        }
                    }
                }
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                
                .overlay(
                    Button(action: {
                        editProfileImage.toggle()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                    })
                    .offset(y: 5)
                    ,alignment: .bottomTrailing
                )
                .offset(y: 50)
                .sheet(isPresented: $editProfileImage, onDismiss: {
                    loadIcon()
                }, content: {
                    ImagePicker(image: $selectedImage)
                })
            }
            
            VStack(alignment: .leading, spacing: 15) {
                
                Text("Name")
                    .foregroundColor(Color.black)
                    .padding(.leading, 10)
                
                TextField("\(displayName)", text: $displayName)
                    .padding(10)
                    .padding(.horizontal, 5)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
                
                Text("Bio")
                    .foregroundColor(Color.black)
                    .padding(.leading, 10)
                
                AutoSizeTextField(text: $bio, hint: "Enter your bio...", containerHeight: $containerHeight)
                    .frame(height: containerHeight < 150 ? containerHeight : 150)
                    .padding(5)
                    .padding(.horizontal, 5)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
            }
            .offset(y: 50)
            .padding(.horizontal, 15)
        }
        .onAppear(perform: {
            self.displayName = fetchDisplayName
            self.bio = fetchBio
        })
        .frame(maxHeight: .infinity, alignment: .top)
        .overlay(
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                })
                
                Spacer()
                
                Button(action: {
                    isProcessing = true
                    EditProfileService.updateBio(bio: bio) {
                        viewModel.updateBio(bio: bio)
                        EditProfileService.updateDisplayname(name: displayName) {
                            viewModel.updateDisplayName(name: displayName)
                            
                            if let icon = profileImage, let bannerImage = bannerImage {
                                ImageUploader.uploadImage(image: icon, path: .icon) { url in
                                    EditProfileService.updateIcon(url: url) {
                                        print("DEBUG: Successfully uploaded image...")
                                        AuthViewModel.shared.currentUser?.profile.profileIconURL = url
                                        
                                        viewModel.user?.profile.profileIconURL = url

                                        return
                                    }
                                }
                                
                                ImageUploader.uploadImage(image: bannerImage, path: .banner) { url in
                                    EditProfileService.updateBanner(url: url) {
                                        AuthViewModel.shared.currentUser?.profile.bannerURL = url
                                        viewModel.user?.profile.bannerURL = url
                                        
                                        return
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                    
                                    isProcessing = false
                                    
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                
                                isProcessing = false
                                
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }, label: {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    }else{
                        Text("Done")
                    }
                })
                
            }
            .foregroundColor(.white)
            .padding()
            ,alignment: .topLeading
        )
    }
    
    private var fetchIconURL: String{
        guard let icon = viewModel.user?.profile.profileIconURL else { return " " }
        return icon
    }
    
    private var fetchBio: String{
        guard let bio = viewModel.user?.profile.bio else { return " " }
        return bio
    }
    
    private var fetchDisplayName: String {
        guard let displayName = viewModel.user?.displayName else { return "" }
        return displayName
    }
}

struct EditProfileService {
    
    //Updates current users bio
    static func updateBio(bio: String, completion: @escaping () -> ()){
        let id = AuthViewModel.shared.currentId
        COLLECTION_USERS.document(id).updateData(["profile.bio":bio]) { error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            completion()
        }
    }
    
    static func updateDisplayname(name: String, completion: @escaping () -> ()){
        let id = AuthViewModel.shared.currentId
        COLLECTION_USERS.document(id).updateData(["profile.displayName": name]) { error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            completion()
        }
    }
    
    static func updateIcon(url: String, completion: @escaping() -> ()){
        let id = AuthViewModel.shared.currentId
        COLLECTION_USERS.document(id).updateData(["profile.profileIconURL": url]) { error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            completion()
        }
    }
    
    static func updateBanner(url: String, completion: @escaping () -> ()){
        let id = AuthViewModel.shared.currentId
        COLLECTION_USERS.document(id).updateData(["profile.bannerURL": url]){ error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            completion()
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
            .environmentObject(ProfileView.ViewModel(profileState: .currentUser))
    }
}
