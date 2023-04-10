import SwiftUI
import MapKit
import CoreLocation

struct RecentLocationsSheet: View {
    @Binding var showSheet: Bool
    @State private var recentLocations = ["Location 1", "Location 2", "Location 3"]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showSheet = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                .frame(width: 44, height: 44)
                .background(Color.white)
                .cornerRadius(22)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Text("Recent Locations")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            
            List(recentLocations, id: \.self) { location in
                Text(location)
                    .font(.system(size: 18))
                    .padding(.vertical, 4)
                    .padding(.vertical, 4)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        .edgesIgnoringSafeArea(.all)
    }
}


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

struct SearchBar: View {
    @Binding var searchText: String
    var placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $searchText)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

struct LocationScreen: View {
    @StateObject private var locationManager = LocationManager()
    @State private var myLocationSearchText: String = ""
    @State private var destinationSearchText: String = ""
    @State private var showRecentLocationsSheet = false
    
    var body: some View {
        ZStack {
            MapView(locationManager: locationManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        SearchBar(searchText: $myLocationSearchText, placeholder: "Current Location")
                    }
                    
                    HStack {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.red)
                        SearchBar(searchText: $destinationSearchText, placeholder: "Destination")
                    }
                    
                    Button(action: {
                        showRecentLocationsSheet = true
                    }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 20))
                            Text("Recent Locations")
                                .font(.system(size: 18))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemBlue))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal)
                
                Spacer()
            }
            
            if showRecentLocationsSheet {
                RecentLocationsSheet(showSheet: $showRecentLocationsSheet)
            }
        }
    }
}


struct LocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        LocationScreen()
    }
}
