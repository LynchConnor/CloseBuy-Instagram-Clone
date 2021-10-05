//
//  ProfileViewModel.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 13/09/2021.
//

import Foundation

enum ProfileState {
    case currentUser
    case userId(id: String)
    case user(user: User)
}


extension ProfileView {
    class ViewModel: ObservableObject {
        @Published var profileState: ProfileState
        @Published var user: User?
        @Published var posts: [Post]
        
        init(profileState: ProfileState, posts: [Post] = [Post]()){
            self.profileState = profileState
            self.posts = posts
            fetchUser()
            fetchLikedPosts()
        }
        
        func updateBio(bio: String){
            self.user?.profile.bio = bio
            if (user?.isCurrentUser) != nil {
                AuthViewModel.shared.currentUser?.profile.bio = bio
            }
        }
        
        func updateDisplayName(name: String){
            self.user?.profile.displayName = name
            if (user?.isCurrentUser) != nil {
                AuthViewModel.shared.currentUser?.profile.displayName = name
            }
        }
        
        
        func fetchLikedPosts(){
            fetchPosts(completion: { [weak self] posts in
                self?.posts = posts
            })
        }
        
        private func fetchPosts(completion: @escaping (([Post]) -> ())){
            
            let id = AuthViewModel.shared.currentId
            
            COLLECTION_USERS.document(id).collection("userLikes").getDocuments { snapshot, error in
                if let error = error {
                    self.posts = []
                    print("DEBUG: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents, !(documents.isEmpty) else { self.posts = []; return }
                
                let id = documents.compactMap({ $0.documentID })
                
                COLLECTION_POSTS.whereField("__name__", in: id).getDocuments { snapshot, error in
                    if let error = error {
                        print("DEBUG: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents, !(documents.isEmpty) else { return }
                    
                    do {
                        try completion(documents.compactMap({ try $0.data(as:  Post.self) }))
                    }catch {
                        self.posts = []
                        print("DEBUG: Error")
                    }
                }
            }
        }
        
        //Fetches and sets the profile user
        private func fetchUser(){
            switch self.profileState {
            case .currentUser:
                guard let user = AuthViewModel.shared.currentUser else { return }
                self.user = user
                ProfileService.fetchStats(user: user) { stats in
                    self.user?.stats = stats
                }
                return
            case .user(let user):
                self.user = user
                ProfileService.fetchStats(user: user) { [weak self] stats in
                    self?.user?.stats = stats
                }
                isUserFollowing(user: user)
                return
            case .userId(let id):
                ProfileService.fetchUser(userId: id) { [weak self] result in
                    switch result {
                    case .success(let user):
                        self?.user = user
                        ProfileService.fetchStats(user: user) { [weak self] stats in
                            self?.user?.stats = stats
                        }
                        self?.isUserFollowing(user: user)
                    case .failure(_):
                        return
                    }
                }
                return
            }
        }
        
        //Check if user is following
        private func isUserFollowing(user: User){
            let id = AuthViewModel.shared.currentId
            
            guard let userId = user.id else { return }
            
            ProfileService.isUserFollowing(currentUserId: id, withId: userId) { [weak self] result in
                self?.user?.isFollowing = result
            }
        }
        
        //Follows the user, if there is an error undo follow ui
        func followUser(){
            self.user?.isFollowing = true
            guard let id = user?.id else { return }
            ProfileService.followUser(userId: id) { error in
                if error != nil {
                    self.user?.isFollowing = false
                }
            }
        }
        
        //Follows the user, if there is an error undo follow ui
        func unfollowUser(){
            self.user?.isFollowing = false
            guard let id = user?.id else { return }
            ProfileService.unfollowUser(userId: id) { error in
                if error != nil {
                    self.user?.isFollowing = true
                }
            }
        }
    }
}
