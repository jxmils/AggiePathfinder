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

        if let initialUserLocation = locationManager.initialUserLocation, !initialRegionSet {
            let region = MKCoordinateRegion(center: initialUserLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            initialRegionSet = true
        }

        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        if let initialUserLocation = locationManager.initialUserLocation, !context.coordinator.userMovedMap {
            let region = MKCoordinateRegion(center: initialUserLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            view.setRegion(region, animated: true)
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
        var userMovedMap = false
        
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
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            userMovedMap = true
        }

    }
}

struct SearchBar: View {
    @Binding var searchText: String
    @Binding var isFocused: Bool
    var placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $searchText, onEditingChanged: { editing in
            isFocused = editing
        })
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(red: 255/255, green: 247/255, blue: 233/255))
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
    @State private var isSearchBarFocused = false

    
    var body: some View {
        ZStack {
            if isSearchBarFocused {
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
            } else {
                MapView(locationManager: locationManager, destinationAnnotation: $destinationAnnotation, initialRegionSet: $initialRegionSet)
                    .edgesIgnoringSafeArea(.all)
            }

            
            VStack {
                VStack(spacing: 8) {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.red)
                            SearchBar(searchText: $destinationSearchText, isFocused: $isSearchBarFocused, placeholder: "Destination")
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
                            .background(Color(red: 255/255, green: 247/255, blue: 233/255))
                        }
                    }
                }
                .padding(.top, 16)
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
