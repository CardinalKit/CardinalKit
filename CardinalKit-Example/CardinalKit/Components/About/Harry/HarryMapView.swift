//
//  MapView.swift
//  Assignment One
//
//  Created by Harry Mellsop on 1/16/21.
//

import SwiftUI
import MapKit

struct HarryMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -36.867484, longitude: 174.792394),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    var body: some View {
        if #available(iOS 14.0, *) {
            Map(coordinateRegion: $region)
        } else {
            // Fallback on earlier versions
        }
    }
}

struct HarryMapView_Previews: PreviewProvider {
    static var previews: some View {
        HarryMapView()
    }
}
