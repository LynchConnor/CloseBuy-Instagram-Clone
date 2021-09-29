//
//  User.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 10/09/2021.
//

import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    
    //Profile
    var profile: Profile
    
    var displayName: String {
        guard let displayName = business?.displayName else { return profile.displayName }
        return displayName
    }
    
    var isFollowing: Bool?
    
    var isNotified: Bool?
    
    var isBusiness: Bool { return business != nil }
    
    var isCurrentUser: Bool { return id == AuthViewModel.shared.currentUser?.id }
    
    //Business
    var business: Business?
    
    //Stats
    var stats: Stats?
}

struct Profile: Codable {
    let username: String
    var displayName: String
    var profileIconURL: String
    
    var email: String?
    var bio: String?
    var bannerURL: String?
}

struct Stats: Codable {
    var followers: Int?
    var following: Int?
    var posts: Int?
}

struct Business: Codable {
    let displayName: String
    let username: String
    
    var location: GeoPoint?
}
