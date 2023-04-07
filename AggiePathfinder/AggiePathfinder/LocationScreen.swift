import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        locationManager.requestLocation()
        
        if let userLocation = locationManager.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        if let userLocation = locationManager.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            view.setRegion(region, animated: true)
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}

struct SearchBarContainer: View {
    @Binding var myLocationSearchText: String
    @Binding var destinationSearchText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Location")
                    .font(.headline)
                Spacer()
                Spacer()
                Spacer()
                TextField("Search", text: $myLocationSearchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Text("Destination")
                    .font(.headline)
                Spacer()
                TextField("Search", text: $destinationSearchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding()
        .background(Color(red: 0.961, green: 0.957, blue: 0.922))
        .cornerRadius(10)
        .frame(height: UIScreen.main.bounds.height * 0.2)
    }
}

struct LocationScreen: View {
    @StateObject private var locationManager = LocationManager()
    @State private var myLocationSearchText: String = ""
    @State private var destinationSearchText: String = ""

    var body: some View {
        ZStack {
            MapView(locationManager: locationManager)
                .edgesIgnoringSafeArea(.all)

            VStack {
                SearchBarContainer(myLocationSearchText: $myLocationSearchText, destinationSearchText: $destinationSearchText)
                    .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

struct LocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        LocationScreen()
    }
}
