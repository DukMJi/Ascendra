import SwiftUI

// Main tab container for the app.
struct MainTabView: View
{
    var body: some View
    {
        TabView
        {
            ContentView()
                .tabItem
                {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ProgressScreen()
                .tabItem
                {
                    Image(systemName: "chart.bar.fill")
                    Text("Progress")
                }
            
            BadgesScreen()
                .tabItem
                {
                    Image(systemName: "star.fill")
                    Text("Badges")
                }
            
            ProfileScreen()
                .tabItem
                {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.ascendraOrange)
    }
}
