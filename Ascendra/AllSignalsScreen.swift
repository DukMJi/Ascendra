import SwiftUI

struct AllSignalsScreen: View
{
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    
    var currentTheme: AppTheme
    {
        return AppTheme(rawValue: selectedTheme) ?? .core
    }
    
    var themeBackground: Color
    {
        return ThemeManager.background(for: currentTheme)
    }
    
    var body: some View
    {
        ZStack
        {
            themeBackground
                .ignoresSafeArea()
            
            ScrollView
            {
                VStack(alignment: .leading, spacing: 16)
                {
                    SignalRow(
                        icon: "eye.fill",
                        message: "Ari noticed your consistency."
                    )
                    
                    SignalRow(
                        icon: "circle.fill",
                        message: "Supported by someone in your Circle."
                    )
                    
                    SignalRow(
                        icon: "flame.fill",
                        message: "John noticed your 3-day streak."
                    )
                    
                    SignalRow(
                        icon: "moon.fill",
                        message: "Sarah noticed your nightly check-ins."
                    )
                }
                .padding()
            }
        }
        .navigationTitle("Signals")
        .navigationBarTitleDisplayMode(.inline)
    }
}
