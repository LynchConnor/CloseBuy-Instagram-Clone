//
//  FeedView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 14/09/2021.
//

import SwiftUI
import Foundation

struct FeedView: View {
    
    @EnvironmentObject var locationManager: LocationManager
    
    @StateObject var viewModel: FeedView.ViewModel = .init()
    
    var body: some View {
        RefreshableScrollView(onRefresh: { done in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.fetchPosts()
                done()
            }
        }) {
            
            if viewModel.posts.count > 0 {
                ForEach(viewModel.posts) { post in
                    PostView(PostView.ViewModel(post: post))
                        .environmentObject(locationManager)
                }
                
            }else{
                PostView(PostView.ViewModel(post: POST_EXAMPLE))
                    .redacted(reason: .placeholder)
                    .disabled(true)
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedView()
        }
    }
}

enum FeedError: Error {
    case error
    case noDocuments
}

extension FeedView {
    
    class ViewModel: ObservableObject {
        
        @Published var posts: [Post]
        
        init(posts: [Post] = [Post]()){
            self.posts = posts
            fetchPosts()
        }
        
        func fetchPosts(){
            FeedService.fetchFollowing { [weak self] result in
                switch result {
                case .success(let following):
                    FeedService.fetchPostDetail(following: following) { [weak self] result in
                        switch result {
                        case .success(let posts):
                            self?.posts = posts
                        case .failure(_):
                            self?.posts = [Post]()
                            return
                        }
                    }
                case .failure(_):
                    self?.posts = [Post]()
                    return
                }
            }
        }
    }
}
