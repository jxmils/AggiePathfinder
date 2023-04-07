//
//  SearchScreen.swift
//  AggiePathfinder
//
//  Created by Jason Miller on 4/6/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct SearchScreen: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var isSearching: Bool
    @State private var searchText: String = ""
    @State private var searchResults: [MKLocalSearchCompletion] = []

    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                }
                TextField("Search for a location", text: $searchText)
                    .padding(.leading, 8)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(Color.white)
            .cornerRadius(20)
            .padding(.top, 16)
            .padding(.horizontal)

            List(searchResults, id: \.self) { completion in
                Text(completion.title)
                    .onTapGesture {
                        // When a suggestion is tapped, search for the selected location and update the map view
                        searchForLocation(completion: completion)
                        isSearching = false
                    }
            }
            .listStyle(GroupedListStyle())
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal)
            .opacity(searchResults.isEmpty ? 0 : 1)
        }
        .onAppear {
            DispatchQueue.main.async {
                UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .background(Color(red: 0.976, green: 0.965, blue: 0.937))
    }

    private func searchForLocation(completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)

        search.start { response, error in
            guard let mapItem = response?.mapItems.first else { return }
            locationManager.location = mapItem.placemark.location
        }
    }
}

struct SearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        SearchScreen(locationManager: LocationManager(), isSearching: .constant(true))
    }
}
