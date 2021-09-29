//
//  ProfileService.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 13/09/2021.
//

import Foundation

enum ProfileError: Error {
    case noUser
    case error
}

class ProfileService {
    //Fetches the user based on their id
    static func fetchUser(userId id: String, completion: @escaping (Result<User, ProfileError>) -> ()) {
        COLLECTION_USERS.document(id).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                completion(.failure(.error))
            }
            
            guard let document = snapshot, document.exists else {
                completion(.failure(.noUser))
                return
            }
            
            do {
                guard let user = try document.data(as: User.self) else { return }
                completion(.success(user))
            }catch {
                print("DEBUG: \(error.localizedDescription)")
                
            }
            
            completion(.failure(.error))
        }
    }
    
    //Check whether the user is following
    static func isUserFollowing(currentUserId: String, withId userId: String, completion: @escaping (Bool) -> ()){
        COLLECTION_FOLLOWING.document(currentUserId).collection("userFollowing").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            guard let document = snapshot, document.exists else { completion(false); return }
            completion(true)
        }
    }
    
    //Fetch follower count
    static func followersCount(id: String, completion: @escaping (Int) -> ()){
        COLLECTION_FOLLOWERS.document(id).collection("userFollowers").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents, !(documents.isEmpty) else { return }
            completion(documents.count)
        }
    }
    
    //Fetch following count
    static func followingCount(id: String, completion: @escaping (Int) -> ()){
        COLLECTION_FOLLOWING.document(id).collection("userFollowing").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents, !(documents.isEmpty) else { return }
            completion(documents.count)
        }
    }
    
    //Check user stats
    static func fetchStats(user: User, completion: @escaping (Stats) -> ()){
        
        guard let userId = user.id else { return }
        
        if user.isBusiness && !(user.isCurrentUser) {
            ProfileService.followersCount(id: userId) { followers in
                ProfileService.postsCount(id: userId) { posts in
                    completion(Stats(followers: followers, posts: posts))
                }
            }
        }else{
            ProfileService.followingCount(id: userId) { following in
                completion(Stats(following: following))
            }
        }
    }
    
    //Fetch post count
    static func postsCount(id: String, completion: @escaping (Int) -> ()){
        COLLECTION_POSTS.whereField("user.id", isEqualTo: id).getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: (Posts Count): \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, !(documents.isEmpty) else { completion(0); return }
            completion(documents.count)
        }
    }
    
    //Follow User
    static func followUser(userId id: String, completion: @escaping (Error?) -> ()){
        guard let currentUserId = AuthViewModel.shared.currentUser?.id else { return }
        COLLECTION_FOLLOWING.document(currentUserId).collection("userFollowing").document(id).setData([:]) { error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                completion(error)
            }
            COLLECTION_FOLLOWERS.document(id).collection("userFollowers").document(currentUserId).setData([:]) { error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    completion(error)
                }
                completion(nil)
            }
        }
    }
    
    //Unfollow User
    static func unfollowUser(userId id: String, completion: @escaping (Error?) -> ()){
        guard let currentUserId = AuthViewModel.shared.currentUser?.id else { return }
        COLLECTION_FOLLOWING.document(currentUserId).collection("userFollowing").document(id).delete() { error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                completion(error)
            }
            COLLECTION_FOLLOWERS.document(id).collection("userFollowers").document(currentUserId).delete() { error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    completion(error)
                }
                completion(nil)
            }
        }
    }
}
