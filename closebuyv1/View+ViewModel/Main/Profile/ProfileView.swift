//
//  ProfileView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 13/09/2021.
//

import SDWebImageSwiftUI
import SwiftUI

struct ProfileView: View {
    
    @State var editIsActive: Bool = false
    
    //MARK: Properties
    @StateObject var viewModel: ViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    init(viewModel: ProfileView.ViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var isFollowing: Bool { return viewModel.user?.isFollowing != false }
    
    //MARK: Body
    var body: some View {
        
        if let user = viewModel.user {
            
            VStack {
                
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .offset(x: -1)
                            .font(.system(size: 17, weight: .semibold))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .padding(10)
                    })
                        .foregroundColor(.black)
                        .clipShape(Circle())
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .zIndex(-1)
                
                ScrollView(showsIndicators: false){
                    
                    VStack(spacing: 0) {
                        
                        ZStack(alignment: .bottomLeading) {
                            
                            StretchingHeader(height: 150) {
                                ZStack {
                                    if let bannerURL = viewModel.user?.profile.bannerURL {
                                        WebImage(url: URL(string: bannerURL))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    }else{
                                        Image("bakery")
                                            .resizable()
                                            .redacted(reason: .placeholder)
                                            .aspectRatio(contentMode: .fill)
                                    }
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            }
                            
                            WebImage(url: URL(string: viewModel.user?.profile.profileIconURL ?? ""))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(SYSTEM_GREEN, lineWidth: 5)
                                )
                                .padding(5)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 5)
                                )
                                .offset(x: 10, y: 50)
                        }
                        
                        VStack(spacing: 5) {
                            
                            HStack {
                                
                                Spacer()
                                
                                if user.isBusiness && !(user.isCurrentUser) {
                                    HStack {
                                        
                                        
                                        Button {
                                            isFollowing ? viewModel.unfollowUser() : viewModel.followUser()
                                        } label: {
                                            Text(isFollowing ? "Unfollow" : "Follow")
                                                .font(.system(size: 14, weight: .semibold))
                                                .frame(width: 175, height: 40)
                                                .foregroundColor(isFollowing ? Color.black : Color.white)
                                                .background(isFollowing ? Color.white : Color.blue)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 3)
                                                        .stroke(Color.gray, lineWidth: isFollowing ? 1 : 0)
                                                )
                                        }
                                        .cornerRadius(3)
                                    }
                                    
                                }else{
                                    Button {
                                        editIsActive.toggle()
                                    } label: {
                                        Text("Edit profile")
                                            .frame(width: 150, height: 40)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                }
                                
                                
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                
                                Text(viewModel.user?.displayName ?? "")
                                    .font(.system(size: 21, weight: .bold))
                                    .foregroundColor(SYSTEM_BLACK)
                                
                                HStack(spacing: 5) {
                                    if user.isBusiness && !(user.isCurrentUser) {
                                        HStack(spacing: 4) {
                                            Text("\(viewModel.user?.stats?.followers ?? 0)").bold()
                                            Text("followers")
                                        }
                                        HStack(spacing: 4) {
                                            Text("\(viewModel.user?.stats?.posts ?? 0)").bold()
                                            Text("posts")
                                        }
                                    }else{
                                        HStack(spacing: 4) {
                                            Text("\(viewModel.user?.stats?.following ?? 0)").bold()
                                            Text("following")
                                        }
                                    }
                                }
                                .font(.system(size: 16))
                                
                                Text(viewModel.user?.profile.bio ?? "")
                                    .font(.system(size: 15, weight: .regular))
                                    .lineSpacing(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(SYSTEM_BLACK)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                HStack(spacing: 2) {
                                    Image("location.pin")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 15, height: 12)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.top, 5)
                            }
                            //MARK: VStack
                            .padding(.vertical, 5)
                            
                            if user.isCurrentUser {
                                
                                VStack(spacing: 5) {
                                    
                                    Text("Liked Posts")
                                        .bold()
                                    
                                    Rectangle()
                                        .frame(height: 2)
                                        .background(Color.gray)
                                        .foregroundColor(Color.gray)
                                    
                                    LazyVGrid(columns: [ GridItem(.flexible(minimum: 0)), GridItem(.flexible(minimum: 0)) ]) {
                                        ForEach(viewModel.posts){ post in
                                            WebImage(url: URL(string: post.imageURL))
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 150)
                                                .cornerRadius(5)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    
                                }
                                .padding(.top, 10)
                                
                            }
                        }
                        .padding(15)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $editIsActive, onDismiss: {
            }, content: {
                
                EditProfileView()
                    .environmentObject(viewModel)
            })
            
            
        }else{
            ProgressView()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    
    static let user = User(profile: Profile(username: "", displayName: "", profileIconURL: "https://firebasestorage.googleapis.com:443/v0/b/closebuyv1.appspot.com/o/AF4D5D26-0063-4598-B870-94AE7866F5AC?alt=media&token=420c3a76-e531-4832-80fa-be135ac405ca", email: "", bio: "", bannerURL: ""), isFollowing: true, business: Business(displayName: "BabyBakes", username: "babyBakes"), stats: Stats(followers: 10, posts: 10))
    
    static var previews: some View {
        ProfileView(viewModel: ProfileView.ViewModel(profileState: .user(user: user)))
    }
}
