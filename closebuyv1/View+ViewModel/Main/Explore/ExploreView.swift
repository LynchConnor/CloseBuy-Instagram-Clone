//
//  ExploreView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 13/09/2021.
//

import Combine
import SwiftUI
import SDWebImageSwiftUI

extension ExploreView {
    class ViewModel: ObservableObject {
        
        //MARK: PROPERTIES
        
        @Published var users: [User] = [User]()
        
        @Published var posts: [Post] = [Post]()
        
        @Published var searchIsActive: Bool = false
        
        @Published var clearIsActive: Bool = false
        
        @Published var searchField: String
        
        private var cancellables = Set<AnyCancellable>()
        
        //MARK: BODY
        
        init(searchField: String = ""){
            self.searchField = searchField
            validateSearchField()
            fetchUsers()
            fetchPosts()
        }
        
        private func fetchUsers(){
            ExploreService.fetchUsers { [weak self] result in
                switch result {
                case .success(let users):
                    self?.users = users
                case .failure(_):
                    return
                }
            }
        }
        
        private func fetchPosts(){
            ExploreService.fetchPosts { [weak self] result in
                switch result {
                case .success(let posts):
                    self?.posts = posts
                case .failure(_):
                    return
                }
            }
        }
        
        private func validateSearchField() {
            $searchField
                .sink { [weak self] value in
                    self?.clearIsActive = (value.count > 0)
                }
                .store(in: &cancellables)
        }
        
        var filteredUsers: [User] {
            let queryLowercased = searchField.lowercased()
            return users.filter({ $0.displayName.lowercased().contains(queryLowercased) })
        }
        
        var filteredPosts: [Post] {
            let queryLowercased = searchField.lowercased()
            return posts.filter({ $0.user.displayName.lowercased().contains(queryLowercased) })
        }
        
        private func hideKeyboard(){
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
        func emptySearchField(){
            self.searchField = ""
        }
        
        func cancelSearching(){
            self.searchIsActive = false
            self.searchField = ""
            hideKeyboard()
        }
    }
}

struct ExploreView: View {
    
    @StateObject var viewModel: ViewModel = .init()
    
    var filteredUsers: [User] {
        return viewModel.searchField.isEmpty ? viewModel.users : (viewModel.filteredUsers.isEmpty ? viewModel.users : viewModel.filteredUsers)
    }
    
    var filteredPosts: [Post] {
        return viewModel.searchField.isEmpty ? viewModel.posts : (viewModel.filteredPosts.isEmpty ? viewModel.posts : viewModel.filteredPosts)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    TextField("", text: $viewModel.searchField)
                    
                    Spacer()
                    if viewModel.clearIsActive {
                        Button(action: {
                            viewModel.emptySearchField()
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        })
                            .transition(.opacity)
                            .animation(.easeIn, value: 0.5)
                    }
                }
                .onTapGesture {
                    withAnimation {
                        viewModel.searchIsActive = true
                    }
                }
                .padding(10)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(5)
                
                if viewModel.searchIsActive {
                    Button(action: {
                        viewModel.cancelSearching()
                    }, label: {
                        Text("Cancel")
                    })
                        .padding(.horizontal, 5)
                        .transition(.move(edge: .trailing))
                        .animation(.easeIn, value: 0.5)
                }
            }
            
            ScrollView(.vertical, showsIndicators: false){
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("Users")
                        .font(.system(size: 24, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)
                    
                    LazyVStack(alignment: .leading, spacing: 12) {
                        
                        ForEach(filteredUsers) { user in
                            NavigationLink (
                                destination: LazyView(ProfileView(viewModel: ProfileView.ViewModel(profileState: .user(user: user)))),
                                label: {
                                    LazyView(ProfileCell(viewModel: ProfileCell.ViewModel(user: user)))
                                }
                            )
                        }
                    }
                    
                }
                .padding(.top, 10)
            
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 15)
        .navigationTitle("")
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExploreView(viewModel: ExploreView.ViewModel(searchField: ""))
        }
    }
}

extension ProfileCell {
    class ViewModel: ObservableObject {
        @Published var user: User
        
        init(user: User){
            self.user = user
        }
        
        func fetchStats(){
            ProfileService.fetchStats(user: user) { stats in
                self.user.stats = stats
                return
            }
        }
    }
}

struct PostCell: View {
    
    let post: Post
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AnimatedImage(url: URL(string: post.imageURL))
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 125)
                .clipped()
            
            VStack {
                Image(systemName: "heart")
                Text("\(2)")
            }
            .font(.system(size: 21, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 25, height: 25)
            .padding(10)
            .background(Color.black.opacity(0.5))
            .clipShape(Circle())
            .padding(5)
        }
        .clipped()
        .cornerRadius(10)
    }
}


struct ProfileCell: View {
    
    @StateObject var viewModel: ProfileCell.ViewModel
    
    init(viewModel: ViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            if let url = viewModel.user.profile.profileIconURL {
                WebImage(url: URL(string: url))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(viewModel.user.displayName)
                    .font(.system(size: 16, weight: .semibold))
                HStack(spacing: 5) {
                    HStack(spacing: 3) {
                        Text("\(viewModel.user.stats?.followers ?? 0)").bold()
                        Text("followers")
                    }
                    HStack(spacing: 3) {
                        Text("\(viewModel.user.stats?.posts ?? 0)").bold()
                        Text("posts")
                    }
                }
            }
        }
        .onAppear(perform: {
            viewModel.fetchStats()
        })
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
