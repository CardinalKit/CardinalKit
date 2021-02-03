//
//  MapView.swift
//  Assignment One
//
//  Created by Colton Swingle on 1/17/21.
//

import SwiftUI
import MapKit

struct MapView: View {
    // Location coordinates for Lake Tahoe
    @State private var region = MKCoordinateRegion(
         center: CLLocationCoordinate2D(latitude: 39.289762, longitude: -120.162877),
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

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
