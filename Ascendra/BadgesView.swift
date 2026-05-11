import SwiftUI

struct BadgesScreen: View
{
    @State private var earnedBadges: [Badge] = []
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    
    let allBadges: [Badge] = [
        Badge(title: "First Check-In", description: "Completed your first goal.", icon: "star.fill"),
        Badge(title: "100 XP", description: "Reached 100 total XP.", icon: "bolt.fill"),
        Badge(title: "3-Day Streak", description: "Stayed consistent for 3 days.", icon: "flame.fill")
    ]
    
    var currentTheme: AppTheme
    {
        return AppTheme(rawValue: selectedTheme) ?? .core
    }
    
    var themeBackground: Color
    {
        return ThemeManager.background(for: currentTheme)
    }
    
    var themeSecondaryText: Color
    {
        return ThemeManager.secondaryText(for: currentTheme)
    }
    
    var body: some View
    {
        ZStack
        {
            themeBackground
                .ignoresSafeArea()
            
            ScrollView
            {
                VStack(alignment: .leading, spacing: 24)
                {
                    Text("Badges")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(earnedBadges.count) / \(allBadges.count) unlocked")
                        .foregroundColor(themeSecondaryText)
                    
                    VStack(spacing: 12)
                    {
                        ForEach(allBadges)
                        { badge in
                            BadgeRow(
                                badge: badge,
                                isUnlocked: hasEarnedBadge(named: badge.title)
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear
        {
            loadBadges()
        }
    }
    
    // Loads earned badges from UserDefaults.
    func loadBadges()
    {
        if let data = UserDefaults.standard.data(forKey: "earnedBadges"),
           let decoded = try? JSONDecoder().decode([Badge].self, from: data)
        {
            earnedBadges = decoded
        }
    }
    
    // Checks whether a badge title is already earned.
    func hasEarnedBadge(named title: String) -> Bool
    {
        return earnedBadges.contains
        {
            $0.title == title
        }
    }
}

struct BadgeRow: View
{
    var badge: Badge
    var isUnlocked: Bool
    
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    
    var currentTheme: AppTheme
    {
        return AppTheme(rawValue: selectedTheme) ?? .core
    }
    
    var themeCard: Color
    {
        return ThemeManager.card(for: currentTheme)
    }
    
    var themeAccent: Color
    {
        return ThemeManager.accent(for: currentTheme)
    }
    
    var themeSecondaryText: Color
    {
        return ThemeManager.secondaryText(for: currentTheme)
    }
    
    var body: some View
    {
        HStack(spacing: 14)
        {
            ZStack
            {
                Circle()
                    .fill(isUnlocked ? themeAccent.opacity(0.18) : Color.white.opacity(0.08))
                    .frame(width: 58, height: 58)
                
                Image(systemName: isUnlocked ? badge.icon : "lock.fill")
                    .foregroundColor(isUnlocked ? themeAccent : .gray)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4)
            {
                Text(badge.title)
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? .white : .gray)
                
                Text(badge.description)
                    .font(.subheadline)
                    .foregroundColor(themeSecondaryText)
            }
            
            Spacer()
            
            if isUnlocked
            {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(themeAccent)
                    .font(.title2)
            }
        }
        .padding()
        .background(themeCard)
        .cornerRadius(18)
        .opacity(isUnlocked ? 1.0 : 0.55)
    }
}
