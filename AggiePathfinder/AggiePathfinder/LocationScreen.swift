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
        ZStack {
            Capsule()
                .fill(Color(red: 0.961, green: 0.957, blue: 0.922))
                .shadow(color: Color(red: 0.2, green: 0.2, blue: 0.2), radius: 8, x: 0, y: 4)
            
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
        }
        .frame(height: UIScreen.main.bounds.height * 0.2)
    }
}

struct LocationScreen: View {
    @StateObject private var locationManager = LocationManager()
    @State private var myLocationSearchText: String = ""
    @State private var destinationSearchText: String = ""
    @State private var isSearching = false
    
    var body: some View {
        ZStack {
            MapView(locationManager: locationManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                NavigationLink(destination: SearchScreen(locationManager: locationManager, isSearching: $isSearching), isActive: $isSearching) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                        }
                        TextField("Search for a location", text: $myLocationSearchText)
                            .padding(.leading, 8)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.top, 16)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .opacity(isSearching ? 0 : 1)
            .animation(.default)
        }
    }
}


struct LocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        LocationScreen()
    }
}
