//
//  Post.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 14/09/2021.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    
    let title: String
    let caption: String
    let imageURL: String
    
    var isLiked: Bool?
    
    var likes: Int
    
    var date: Timestamp = .init()
    
    let user: ProfileDetails
}

struct ProfileDetails: Codable {
    var id: String
    let displayName: String
    let iconURL: String
    var location: GeoPoint?
}

let POST_EXAMPLE = Post(title: "", caption: "", imageURL: "https://firebasestorage.googleapis.com:443/v0/b/closebuyv1.appspot.com/o/AF4D5D26-0063-4598-B870-94AE7866F5AC?alt=media&token=420c3a76-e531-4832-80fa-be135ac405ca", likes: 5, user: ProfileDetails(id: "YHqaSKnll4hw2rJLjzcPgyDjFEP2", displayName: "Babybakes", iconURL: ""))
