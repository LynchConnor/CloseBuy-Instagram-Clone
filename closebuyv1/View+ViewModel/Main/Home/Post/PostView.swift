//
//  PostView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 14/09/2021.
//

import Firebase
import CoreLocation
import SwiftUI
import SDWebImageSwiftUI

extension PostView {
    class ViewModel: ObservableObject {
        @Published var post: Post
        
        init(post: Post){
            self.post = post
            isLiked()
        }
        
        func likePost(){
            self.post.isLiked = true
            PostService.likePost(withId: post.id ?? "") { [weak self] error in
                if let _ = error {
                    self?.post.isLiked = false
                }
            }
        }
        
        func unLikePost(){
            self.post.isLiked = false
            PostService.likePost(withId: post.id ?? "") { [weak self] error in
                if let _ = error {
                    self?.post.isLiked = true
                }
            }
        }
        
        private func isLiked(){
            guard let id = post.id else { return }
            PostService.isLiked(withId: id) { [weak self] response in
                self?.post.isLiked = response
            }
        }
    }
}

struct PostView: View {
    
    @StateObject var viewModel: PostView.ViewModel
    
    @EnvironmentObject var locationManager: LocationManager
    
    init(_ viewModel: PostView.ViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var isLiked: Bool {
        guard let isLiked = viewModel.post.isLiked else {
            return false
        }
        return isLiked
    }
    
    var distance: String {
        
        let formatter = MeasurementFormatter()
        
        guard let locationA = viewModel.post.user.location else { return "0" }
        guard let locationB = locationManager.currentLocation else { return "0" }
        
        let distance = locationB.distance(from: CLLocation(latitude: locationA.latitude, longitude: locationA.longitude))
        
        formatter.unitStyle = .short
        let distanceInMetres = Measurement(value: Double(distance), unit: UnitLength.kilometers)
        
        return "\(formatter.string(from: distanceInMetres))"
    }
    
    var body: some View {
        VStack(spacing: 5) {
            HStack(alignment: .bottom) {
                
                //MARK: Profile Navigation
                NavigationLink(
                    destination: ProfileView(viewModel: ProfileView.ViewModel(profileState: .userId(id: viewModel.post.user.id))),
                    label: {
                        HStack(spacing: 5) {
                            
                            
                            WebImage(url: URL(string: viewModel.post.user.iconURL))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .padding(3)
                                .overlay(
                                    Circle()
                                        .stroke(SYSTEM_GREEN, lineWidth: 2)
                                )
                                .padding(1)
                            
                            Text("@\(viewModel.post.user.displayName)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(SYSTEM_BLACK)
                        }
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    })
                    .padding(.leading, 15)
                    .background(Color.white)
                    .cornerRadius(10, corners: [.topRight])
                
                //MARK: Business distance from user
                
                HStack(spacing: 2) {
                    Image("location.pin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("\(distance)")
                }
                .foregroundColor(SYSTEM_BLACK)
                .frame(maxHeight: .infinity)
                .padding(.leading, 5)
                .padding(.trailing, 20)
                .font(.system(size: 13, weight: .regular))
            }
            .padding(.top, 10)
            .background(Color.init(red: 244/255, green: 244/255, blue: 244/255))
            .padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 5) {
                
                //MARK: Post Image
                WebImage(url: URL(string: viewModel.post.imageURL))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 350)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)
                    .cornerRadius(10)
                    .overlay(
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.25), Color.clear, Color.clear, Color.clear]), startPoint: .bottom, endPoint: .top))
                            .cornerRadius(10)
                    )
                    .overlay(
                        HStack(alignment: .bottom) {
                            Text("\(Text("@\(viewModel.post.user.displayName)").bold()) \(viewModel.post.caption)")
                                .shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 0)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .lineSpacing(3)
                            
                            Spacer()
                            
                            Button(action: {
                                isLiked ? viewModel.unLikePost() : viewModel.likePost()
                            }, label: {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(isLiked ? .red : .white)
                                    .font(.system(size: 21, weight: .semibold))
                                    .padding(10)
                            })
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        ,alignment: .bottomLeading
                    )
                
                //MARK: Post Details
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("\(viewModel.post.title)")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(SYSTEM_BLACK)
                    
                    HStack {
                        
                        Spacer()
                        
                        Text("\(convertTimestamp(withDate: viewModel.post.date.dateValue())) ago")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.top, 10)
                .padding(.bottom, 5)
                
            }
            .padding(.horizontal, 15)
        }
        .background(Color.white)
        
        //Remove navigation
        .statusBar(hidden: true)
        .navigationBarHidden(true)
        .navigationBarTitle("")
    }
    
    func convertTimestamp(withDate date: Date) -> String {
        let format = DateComponentsFormatter()
        format.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth, .month]
        format.maximumUnitCount = 1
        format.unitsStyle = .abbreviated
        return format.string(from: date, to: Date()) ?? ""
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(PostView.ViewModel(post: POST_EXAMPLE))
    }
}
