//
//  FeedService.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 14/09/2021.
//

import Foundation

struct FeedService {
    
    static func fetchPostDetail(following: [String], completion: @escaping (Result<[Post], FeedError>) -> ()) {
        COLLECTION_POSTS.whereField("user.id", in: following).getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
            }
            
            guard let documents = snapshot?.documents, !(documents.isEmpty) else { completion(.failure(.noDocuments))
                return
            }
            
            do {
                let posts = try documents.compactMap({ try $0.data(as: Post.self) })
                completion(.success(posts))
            }catch {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
        }
    }
    
    static func fetchFollowing(completion: @escaping (Result<[String], FeedError>) -> ()){
        guard let id = AuthViewModel.shared.currentUser?.id else { return }
        COLLECTION_FOLLOWING.document(id).collection("userFollowing").getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                completion(.failure(.error))
                return
            }
            
            guard let documents = snapshot?.documents, !(documents.isEmpty) else {
                completion(.failure(.noDocuments))
                return
            }
            
            completion(.success(documents.compactMap({ $0.documentID })))
            
        }
    }
}
