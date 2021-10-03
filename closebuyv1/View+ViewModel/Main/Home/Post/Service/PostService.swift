//
//  PostService.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 16/09/2021.
//

import Foundation

struct PostService {
    
    static func likePost(withId postId: String, likes: Int, completion: @escaping (Error?) -> ()){
        let userId = AuthViewModel.shared.currentId
        COLLECTION_POSTS.document(postId).collection("postLikes").document(userId).setData([:]){ error in
            COLLECTION_USERS.document(userId).collection("userLikes").document(postId).setData([:]) { error in
                COLLECTION_POSTS.document(postId).updateData(["likes": likes]) { _ in
                    completion(error)
                }
            }
        }
    }
    
    static func unlikePost(withId postId: String, likes: Int, completion: @escaping (Error?) -> ()){
        let userId = AuthViewModel.shared.currentId
        COLLECTION_POSTS.document(postId).collection("postLikes").document(userId).delete() { _ in
            COLLECTION_USERS.document(userId).collection("userLikes").document(postId).delete() { error in
                COLLECTION_POSTS.document(postId).updateData(["likes": likes]) { _ in
                    completion(error)
                }
            }
        }
    }
    
    static func isLiked(withId postId: String, completion: @escaping (Bool) -> ()){
        let userId = AuthViewModel.shared.currentId
        
        COLLECTION_USERS.document(userId).collection("userLikes").document(postId).getDocument { snapshot, error in
            if let _ = error {
                completion(false)
            }
            
            guard let document = snapshot, document.exists else { completion(false); return }
            completion(true)
        }
    }
}
