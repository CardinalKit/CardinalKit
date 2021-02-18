//
//  ContentView.swift
//  Assignment One
//

import SwiftUI
import MapKit

struct CollinView: View {
    
    @State var isModal: Bool = false

    var modal: some View {
        CollinMapView()
    }
    
    var body: some View {
        
        ZStack(alignment: /*@START_MENU_TOKEN@*/Alignment(horizontal: .center, vertical: .center)/*@END_MENU_TOKEN@*/, content: {
        
            VStack(alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                
                ProfileView()
                
                Divider()
                
                Group {
                    Text("Bio: ").bold()
                        +
                    Text("Hello! My name is Collin, and I'm a senior working towards a B.S. and M.S. in computer science. I am especially interested in applications of software + AI to medicine. Outside of school/work, I enjoy spending time outdoors: skiing ⛷, mountain biking 🚵‍♀️, and SCUBA diving 🤿. This quarter, I'm living in Tahoe, CA with some of my friends from Stanford. Three of us are taking this class together! Click below to see where we are!")
                }
                .padding(.horizontal, 25)
                .font(.body)
                
                Button("Show Map") {
                    self.isModal = true
                }.sheet(isPresented: $isModal, content: {
                    self.modal
                }).padding()
                
            })
        })
    }
}

struct PinItem: Identifiable {
     let id = UUID()
     let coordinate: CLLocationCoordinate2D
 }

struct CollinView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CollinView()
        }
    }
}
