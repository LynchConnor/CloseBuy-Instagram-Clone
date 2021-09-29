//
//  Constants.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 11/09/2021.
//

import SwiftUI
import Firebase

//MARK:- Firebase Shortcuts
let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_POSTS = Firestore.firestore().collection("posts")
let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")

//MARK:- SYSTEM COLOURS
let SYSTEM_ORANGE: Color = Color.init(red: 240/255, green: 164/255, blue: 62/255)

//MARK:- Lazy Loading
struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}


//MARK:- StrechingHeader
struct StretchingHeader<Content: View>: View {
    let height: CGFloat
    let content: () -> Content
    
    var body: some View {
        GeometryReader { geo in
            content()
                .frame(width: geo.size.width, height: self.getHeightForHeaderImage(geo))
                .clipped()
                .offset(x: 0, y: self.getOffsetForHeaderImage(geo))
        }
        .frame(height: height)
    }
    
    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    // 2
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        
        // Image was pulled down
        if offset > 0 {
            return -offset
        }
        else if offset > 0 {
            return offset
        }
        
        
        return 0
    }
    
    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height

        if offset > 0 {
            return imageHeight + offset
        }

        return imageHeight
    }
}

//MARK:- Cornered Radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//MARK:- Hide Keyboard
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
