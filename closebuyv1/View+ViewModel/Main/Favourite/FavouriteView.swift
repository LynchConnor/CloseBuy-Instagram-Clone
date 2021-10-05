//
//  FavouriteView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 04/10/2021.
//

import SwiftUI

extension FavouriteView {
    class ViewModel: ObservableObject {
        @Published var posts: [Post]
        
        init(posts: [Post] = [Post]()) {
            self.posts = posts
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
    }
}

struct FavouriteView: View {
    
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel = .init()){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        RefreshableScrollView(onRefresh: { done in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.fetchLikedPosts()
                done()
            }
        }, content: {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.posts) { post in
                        Image("bakery")
                            .resizable()
                            .frame(height: 200)
                            .clipped()
                    }
                }
                .padding(.horizontal, 15)
            }
            .onAppear {
                viewModel.fetchLikedPosts()
            }
        })
    }
}

struct FavouriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteView()
    }
}
