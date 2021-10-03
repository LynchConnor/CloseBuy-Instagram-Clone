//
//  ExploreService.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 14/09/2021.
//

import Foundation

enum ExploreError: Error {
    case error
    case noDocuments
}

struct ExploreService {
    static func fetchUsers(completion: @escaping (Result<[User], ExploreError>) -> ()){
        COLLECTION_USERS.getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                completion(.failure(.error))
                return
            }
            
            guard let documents = snapshot?.documents, !(documents.isEmpty) else {
                completion(.failure(.noDocuments));
                return
            }
            
            do {
                let users = try documents.compactMap({ try $0.data(as: User.self) }).filter({ !($0.isCurrentUser) && ($0.isBusiness) })
                completion(.success(users))
            }catch {
                print("DEBUG: \(error.localizedDescription)")
                completion(.failure(.error))
                return
            }
        }
    }
    
    static func fetchPosts(completion: @escaping (Result<[Post], ExploreError>) -> ()){
        COLLECTION_POSTS.getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                completion(.failure(.error))
                return
            }
            
            guard let documents = snapshot?.documents, !(documents.isEmpty) else {
                completion(.failure(.noDocuments))
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
}
