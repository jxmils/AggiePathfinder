import SwiftUI

struct ContentView: View {
    @State private var isLocationScreenActive = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    Text("Aggie Pathfinder")
                        .font(.system(size: 36, weight: .bold))
                        .padding(.bottom, 16)
                    
                    Text("Find your way around campus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(.bottom, 32)
                    
                    Image("GDSC")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    
                    Spacer()
                    
                    NavigationLink(destination: LocationScreen(), isActive: $isLocationScreenActive) {
                        Text("Launch")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.86, green: 0.08, blue: 0.24))
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 16)
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.4, green: 0.75, blue: 1.0), Color(red: 1.0, green: 0.8, blue: 0.4)]), startPoint: .top, endPoint: .bottom))
                .edgesIgnoringSafeArea(.all)
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
