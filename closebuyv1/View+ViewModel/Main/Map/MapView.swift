//
//  MapView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 17/09/2021.
//

import SwiftUI
import MapKit


struct MapView: View {
    
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(coordinateRegion: $locationManager.currentRegion, interactionModes: .all, showsUserLocation: true)
                .edgesIgnoringSafeArea(.all)
                .navigationTitle("")
                .navigationBarHidden(true)
            
            Button {
            } label: {
                Image(systemName: "location.circle.fill")
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }
            .padding(10)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
