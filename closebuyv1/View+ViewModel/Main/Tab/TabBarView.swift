//
//  TabBarView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 11/09/2021.
//

import SwiftUI

struct TabBarView: View {
    
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(locationManager)
                .tabItem { Image(systemName: "house") }
            
            ExploreView()
                .environmentObject(locationManager)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
            
            MapView()
                .environmentObject(locationManager)
                .tabItem {
                    Image(systemName: "map")
                }
            
            FavouriteView()
                .tabItem {
                    Image(systemName: "heart")
                }
        }
        
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
