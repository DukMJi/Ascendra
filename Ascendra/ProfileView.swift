import SwiftUI

struct ProfileScreen: View
{
    @AppStorage("xp") private var xp = 120
    @AppStorage("streak") private var streak = 5
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    @AppStorage("displayName") private var displayName = "Tommy"
    @AppStorage("profileInitial") private var profileInitial = "T"
    @State private var showEditProfile = false
    
    let themeColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var currentTheme: AppTheme
    {
        return AppTheme(rawValue: selectedTheme) ?? .core
    }
    
    var themeBackground: Color
    {
        return ThemeManager.background(for: currentTheme)
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
    
    var currentLevel: Int
    {
        return (xp / 100) + 1
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
                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12)
                    {
                        Circle()
                            .fill(themeAccent.opacity(0.20))
                            .frame(width: 90, height: 90)
                            .overlay(
                                Text(profileInitial)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeAccent)
                            )
                        
                        Text(displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Level \(currentLevel)")
                            .foregroundColor(themeSecondaryText)
                        
                        Button
                        {
                            showEditProfile = true
                        } label:
                        {
                            Text("Edit Profile")
                                .font(.caption)
                                .foregroundColor(themeAccent)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeCard)
                    .cornerRadius(20)
                    
                    VStack(spacing: 12)
                    {
                        ProfileStatRow(title: "Total XP", value: "\(xp)", icon: "bolt.fill")
                        ProfileStatRow(title: "Current Streak", value: "\(streak)", icon: "flame.fill")
                    }
                    
                    VStack(alignment: .leading, spacing: 14)
                    {
                        Text("Themes")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: themeColumns, spacing: 12)
                        {
                            ForEach(AppTheme.allCases, id: \.self)
                            { theme in
                                ThemeOptionCard(
                                    theme: theme,
                                    selectedTheme: $selectedTheme,
                                    currentLevel: currentLevel
                                )
                            }
                        }
                    }
                    .padding()
                    .background(themeCard)
                    .cornerRadius(20)
                    
                    Spacer()
                }
                .padding()
                
                .sheet(isPresented: $showEditProfile)
                {
                    EditProfileSheet(
                        displayName: $displayName,
                        profileInitial: $profileInitial
                    )
                }
            }
        }
    }
}

struct ProfileStatRow: View
{
    var title: String
    var value: String
    var icon: String
    
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
            Image(systemName: icon)
                .foregroundColor(themeAccent)
                .frame(width: 28)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .foregroundColor(themeSecondaryText)
        }
        .padding()
        .background(themeCard)
        .cornerRadius(16)
    }
}

struct ThemeOptionCard: View
{
    var theme: AppTheme
    @Binding var selectedTheme: String
    var currentLevel: Int
    
    var isUnlocked: Bool
    {
        return currentLevel >= theme.requiredLevel
    }
    
    var isSelected: Bool
    {
        return selectedTheme == theme.rawValue
    }
    
    var body: some View
    {
        Button
        {
            if isUnlocked
            {
                selectedTheme = theme.rawValue
            }
        } label:
        {
            VStack(alignment: .leading, spacing: 10)
            {
                HStack
                {
                    Circle()
                        .fill(ThemeManager.accent(for: theme))
                        .frame(width: 26, height: 26)
                    
                    Spacer()
                    
                    if isSelected
                    {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ThemeManager.accent(for: theme))
                    }
                    else if !isUnlocked
                    {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Text(theme.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(isUnlocked ? "Unlocked" : "Level \(theme.requiredLevel)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .background(ThemeManager.card(for: theme))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? ThemeManager.accent(for: theme) : Color.white.opacity(0.08), lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.25), value: isSelected)
            .opacity(isUnlocked ? 1.0 : 0.45)
        }
        .buttonStyle(.plain)
    }
}
