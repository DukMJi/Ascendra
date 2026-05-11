import SwiftUI

struct StatCard: View
{
    let icon: String
    let value: String
    let label: String
    
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
        HStack(spacing: 8)
        {
            Image(systemName: icon)
                .foregroundColor(themeAccent)
            
            VStack(alignment: .leading, spacing: 2)
            {
                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(themeSecondaryText)
            }
        }
        .padding(10)
        .background(themeCard)
        .cornerRadius(14)
    }
}
