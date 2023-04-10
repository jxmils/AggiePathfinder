import SwiftUI
import MapKit
import CoreLocation
import Combine

class SearchResults: NSObject, ObservableObject {
    @Published var completions: [MKLocalSearchCompletion] = []
    private var searchCompleter = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        searchCompleter.delegate = self
    }
    
    func search(query: String) {
        searchCompleter.queryFragment = query
    }
}

extension SearchResults: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error fetching search results: \(error.localizedDescription)")
    }
}

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
    @Binding var destinationAnnotation: MKPointAnnotation?
    @Binding var initialRegionSet: Bool
    
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
        if let userLocation = locationManager.location, !initialRegionSet {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            view.setRegion(region, animated: true)
            initialRegionSet = true
        }
        
        // Remove existing destination annotations and routes
        view.removeAnnotations(view.annotations.filter { $0 !== view.userLocation })
        view.removeOverlays(view.overlays)
        
        // Add destination annotation and draw route
        if let destinationAnnotation = destinationAnnotation {
            view.addAnnotation(destinationAnnotation)
            drawRoute(from: locationManager.location?.coordinate, to: destinationAnnotation.coordinate, on: view)
        }
    }
    
    func drawRoute(from source: CLLocationCoordinate2D?, to destination: CLLocationCoordinate2D, on mapView: MKMapView) {
        guard let source = source else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
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
    @StateObject private var searchResults = SearchResults()
    @State private var showRecentLocationsSheet = false
    @State private var destinationAnnotation: MKPointAnnotation? = nil
    @State private var initialRegionSet = false

    
    var body: some View {
        ZStack {
            MapView(locationManager: locationManager, destinationAnnotation: $destinationAnnotation, initialRegionSet: $initialRegionSet)
                .edgesIgnoringSafeArea(.all)

            
            VStack {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        SearchBar(searchText: $myLocationSearchText, placeholder: "Current Location")
                    }
                    
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.red)
                            SearchBar(searchText: $destinationSearchText, placeholder: "Destination")
                                .onChange(of: destinationSearchText) { query in
                                    searchResults.search(query: query)
                                }
                        }
                        
                        if !searchResults.completions.isEmpty {
                            List(searchResults.completions, id: \.self) { completion in
                                Button(action: {
                                    // Get the selected location's coordinate
                                    let request = MKLocalSearch.Request(completion: completion)
                                    let search = MKLocalSearch(request: request)
                                    search.start { (response, error) in
                                        guard let coordinate = response?.mapItems[0].placemark.coordinate else { return }
                                        
                                        // Update destination annotation
                                        let annotation = MKPointAnnotation()
                                        annotation.coordinate = coordinate
                                        destinationAnnotation = annotation
                                    }
                                    
                                    // Clear the search results
                                    searchResults.completions.removeAll()
                                    destinationSearchText = completion.title
                                }) {
                                    Text(completion.title)
                                        .font(.system(size: 18))
                                        .padding(.vertical, 4)
                                        .padding(.vertical, 4)
                                }
                            }
                            .background(Color(.systemGray6))
                        }
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
