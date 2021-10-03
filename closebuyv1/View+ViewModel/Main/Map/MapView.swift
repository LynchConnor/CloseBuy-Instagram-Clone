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
        Map(coordinateRegion: $locationManager.currentRegion, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none)
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("")
            .navigationBarHidden(true)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
