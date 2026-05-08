import SwiftUI

// Available themes in the app.
enum AppTheme: String, CaseIterable
{
    case core = "Core"
    case bloom = "Bloom"
    case mist = "Mist"
    case ember = "Ember"
}

// Handles app theme colors.
struct ThemeManager
{
    static func background(for theme: AppTheme) -> Color
    {
        switch theme
        {
        case .core:
            return Color(red: 15/255, green: 17/255, blue: 21/255)
        case .bloom:
            return Color(red: 247/255, green: 203/255, blue: 202/255)
        case .mist:
            return Color(red: 25/255, green: 29/255, blue: 35/255)
        case .ember:
            return Color(red: 16/255, green: 17/255, blue: 18/255)
        }
    }
    
    static func card(for theme: AppTheme) -> Color
    {
        switch theme
        {
        case .core:
            return Color(red: 26/255, green: 31/255, blue: 39/255)
        case .bloom:
            return Color(red: 208/255, green: 220/255, blue: 219/255)
        case .mist:
            return Color(red: 35/255, green: 45/255, blue: 55/255)
        case .ember:
            return Color(red: 61/255, green: 77/255, blue: 85/255)
        }
    }
    
    static func accent(for theme: AppTheme) -> Color
    {
        switch theme
        {
        case .core:
            return Color(red: 243/255, green: 112/255, blue: 30/255)
        case .bloom:
            return Color(red: 247/255, green: 203/255, blue: 202/255)
        case .mist:
            return Color(red: 126/255, green: 145/255, blue: 159/255)
        case .ember:
            return Color(red: 197/255, green: 139/255, blue: 99/255)
        }
    }
    
    static func secondaryText(for theme: AppTheme) -> Color
    {
        return Color(red: 154/255, green: 164/255, blue: 178/255)
    }
}

// Keeps your old Color names working for now.
extension Color
{
    static let ascendraBackground = ThemeManager.background(for: .core)
    static let ascendraCard = ThemeManager.card(for: .core)
    static let ascendraOrange = ThemeManager.accent(for: .core)
    static let secondaryText = ThemeManager.secondaryText(for: .core)
}
