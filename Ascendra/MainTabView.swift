import SwiftUI

// Main tab container for the app.
struct MainTabView: View
{
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    
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
            
            CircleScreen()
                .tabItem
                {
                    Image(systemName: "circle.grid.2x2.fill")
                    Text("Circle")
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
        .accentColor(currentAccent)
        .toolbarBackground(currentBackground, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .preferredColorScheme(.dark)
    }
    
    var currentTheme: AppTheme
    {
        return AppTheme(rawValue: selectedTheme) ?? .core
    }
    
    var currentBackground: Color
    {
        return ThemeManager.background(for: currentTheme)
    }
    
    var currentAccent: Color
    {
        return ThemeManager.accent(for: currentTheme)
    }
}
