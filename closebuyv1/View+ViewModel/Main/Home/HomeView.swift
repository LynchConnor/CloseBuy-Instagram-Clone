//
//  HomeView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 11/09/2021.
//

import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore
import SDWebImageSwiftUI

let SYSTEM_GREEN: Color = Color.init(red: 0/255, green: 155/255, blue: 150/255)

let SYSTEM_BLACK: Color = Color.init(red: 56/255, green: 56/255, blue: 54/255)


struct HomeView: View {
    
    @State var selected: String = "Following"
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var locationManager: LocationManager
    
    @State var isActive: Bool = false
    
    private var isBusiness: Bool {
        guard let isBusiness = AuthViewModel.shared.currentUser?.isBusiness else { return false }
        return isBusiness
    }
    
    private var iconURL: String? { return AuthViewModel.shared.currentUser?.profile.profileIconURL ?? nil }
    
    var body: some View {
        VStack {
            HStack {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image("menu")
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: 25, height: 25)
                        .foregroundColor(.black)
                }
                .padding(8)
                .background(Color.black.opacity(0.1))
                .clipShape(Circle())
                
                Spacer()
                
                NavigationLink (
                    destination: LazyView(ProfileView(viewModel: ProfileView.ViewModel(profileState: .currentUser))),
                    label: {
                    VStack {
                        if let url = iconURL {
                            WebImage(url: URL(string: url))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                        }
                    }
                    .padding(3)
                    .overlay(
                        Circle()
                            .stroke(SYSTEM_GREEN, lineWidth: 2)
                    )
                })
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            
            CustomTabView(selected: $selected, selectedItems: ["Following", "Near you"])
            
            FeedView()
                .environmentObject(locationManager)
        }
        .overlay(
            VStack(spacing: 0) {
                if isBusiness {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .foregroundColor(SYSTEM_GREEN)
                        .onTapGesture {
                            isActive.toggle()
                        }
                }
            }
            .padding(10)
            ,alignment: .bottomTrailing
        )
        .sheet(isPresented: $isActive, content: {
            CreatePostView()
        })
        .navigationTitle("")
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }
}

struct CustomTabView: View {
    
    @Namespace var namespace
    @Binding var selected: String
    
    var selectedItems: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(selectedItems, id: \.self) { item in
                    Text(item)
                        .foregroundColor(selected == item ? .black : .gray)
                        .bold()
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            Color.clear
                                .frame(height: 2)
                                .matchedGeometryEffect(id: item, in: namespace, properties: .frame, isSource: true)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        )
                        .onTapGesture {
                            DispatchQueue.main.async {
                                withAnimation {
                                    self.selected = item
                                }
                            }
                        }
                }
                .background(Color.black
                        .matchedGeometryEffect(id: selected, in: namespace, properties: .frame, isSource: false)
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(LocationManager())
            .padding(.vertical, 50)
    }
}

struct CreatePostView: View {
    
    @State var inputImage: UIImage?
    @State var image: Image?
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var isActive: Bool = false
    
    @State var isProcessing: Bool = false
    
    private func loadImage(){
        guard let image = inputImage else { return }
        self.image = Image(uiImage: image)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.turn.up.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .frame(width: 75, alignment: .leading)
                
                Spacer()
                
                Text("Create Post")
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
                
                Button {
                    isProcessing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isProcessing = false
                    }
                } label: {
                    ZStack(alignment: .center) {
                        if isProcessing {
                            ProgressView()
                        }else{
                            Text("Save")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .frame(width: 75, alignment: .trailing)
                }
                
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 15)
            .foregroundColor(.black)
            
            VStack {
                
                ZStack {
                    
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFill()
                    }else{
                    
                        Rectangle()
                    }
                }
                .frame(maxHeight: 200)
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                .onTapGesture {
                    isActive.toggle()
                }
            }
            .padding(10)
        }
        .sheet(isPresented: $isActive, onDismiss: {
            loadImage()
        }, content: {
            ImagePicker(image: $inputImage)
        })
        .padding(.vertical, 15)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct SettingsView: View {
    
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Text("Settings")
            Button {
                AuthViewModel.shared.signOut()
            } label: {
                Text("sign out")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}
