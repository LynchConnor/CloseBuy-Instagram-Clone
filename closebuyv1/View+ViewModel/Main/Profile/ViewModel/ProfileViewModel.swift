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
        
        init(profileState: ProfileState){
            self.profileState = profileState
            
            fetchUser()
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
