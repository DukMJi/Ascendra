import SwiftUI

struct SignalRow: View
{
    let icon: String
    let message: String
    
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    
    var currentTheme: AppTheme
    {
        return AppTheme(rawValue: selectedTheme) ?? .core
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
        HStack(spacing: 10)
        {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(themeAccent)
                .frame(width: 22, height: 22)
                .background(themeAccent.opacity(0.15))
                .clipShape(Circle())
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(themeSecondaryText)
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
