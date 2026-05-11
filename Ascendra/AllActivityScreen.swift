import SwiftUI

struct AllActivityScreen: View
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
                VStack(alignment: .leading, spacing: 12)
                {
                    FeedRow(
                        name: "John",
                        action: "checked in on",
                        goal: "Gym",
                        note: "Leg day done",
                        success: true
                    )
                    
                    FeedRow(
                        name: "Sarah",
                        action: "checked in on",
                        goal: "Reading",
                        note: "Finished 10 pages",
                        success: true
                    )
                    
                    FeedRow(
                        name: "Ari",
                        action: "missed",
                        goal: "Study",
                        note: nil,
                        success: false
                    )
                    
                    FeedRow(
                        name: "Tommy",
                        action: "checked in on",
                        goal: "Coding",
                        note: "Finished SwiftUI work",
                        success: true
                    )
                }
                .padding()
            }
        }
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.inline)
    }
}
