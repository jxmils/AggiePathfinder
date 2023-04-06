//
//  ContentView.swift
//  AggiePathfinder
//
//  Created by Jason Miller on 4/6/23.
//

import SwiftUI

struct LogoView: View {
    var imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
    }
}

struct ContentView: View {
    @State private var isLocationScreenActive = false

    var body: some View {
        NavigationView {
            VStack {
                Image("GDSC.png")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 40)
                
                NavigationLink(destination: LocationScreen(), isActive: $isLocationScreenActive) {
                    Text("Launch")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background((Color(red: 0.86, green: 0.08, blue: 0.24)))
                        .cornerRadius(8)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
