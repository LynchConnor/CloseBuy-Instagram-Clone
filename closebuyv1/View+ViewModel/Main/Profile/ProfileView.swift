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
            
            ScrollView(showsIndicators: false){
                
                GeometryReader { proxy in
                    
                    VStack(spacing: 0) {
                        
                        ZStack(alignment: .bottomLeading) {
                            
                            StretchingHeader(height: 125) {
                                ZStack {
                                    if let bannerURL = viewModel.user?.profile.bannerURL {
                                        WebImage(url: URL(string: bannerURL))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    }else{
                                        
                                        Image("bakery")
                                            .resizable()
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
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal)
                                        .background(SYSTEM_GREEN)
                                        .cornerRadius(10)
                                    }
                                    
                                }else{
                                    Button {
                                        editIsActive.toggle()
                                    } label: {
                                        Text("Edit profile")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .background(SYSTEM_GREEN)
                                    .cornerRadius(10)
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
                                    
                                    Text("357 Rayne Road, London, CM7 2QQ")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.top, 5)
                            }
                            .padding(.top, 5)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(1...5, id: \.self){ post in
                                        Image("bakery")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 200, height: 100)
                                    }
                                }
                            }
                        }
                        .padding(15)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .overlay(
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }, label: {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .offset(x: -1)
                                    .font(.system(size: 17, weight: .semibold))
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                                    .padding(10)
                            })
                                .background(Color.black.opacity(0.65))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            
                            Spacer()
                            
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(y: -(proxy.frame(in: .global).minY) + 25)
                        ,alignment: .top
                    )
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
