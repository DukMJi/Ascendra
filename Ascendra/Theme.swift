import SwiftUI

// Available themes in the app.
enum AppTheme: String, CaseIterable
{
    case core = "Core"
    case bloom = "Bloom"
    case mist = "Mist"
    case ember = "Ember"
    case ocean = "Ocean"
    case forest = "Forest"
    case midnight = "Midnight"
    
    // Level needed to unlock each theme.
    var requiredLevel: Int
    {
        switch self
        {
        case .core:
            return 1
        case .bloom:
            return 2
        case .mist:
            return 3
        case .ember:
            return 4
        case .ocean:
            return 5
        case .forest:
            return 6
        case .midnight:
            return 7
        }
    }
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
        case .ocean:
            return Color(red: 10/255, green: 24/255, blue: 38/255)
        case .forest:
            return Color(red: 14/255, green: 28/255, blue: 21/255)
        case .midnight:
            return Color(red: 9/255, green: 10/255, blue: 20/255)
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
        case .ocean:
            return Color(red: 18/255, green: 45/255, blue: 66/255)
        case .forest:
            return Color(red: 28/255, green: 52/255, blue: 39/255)
        case .midnight:
            return Color(red: 22/255, green: 24/255, blue: 45/255)
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
        case .ocean:
            return Color(red: 67/255, green: 176/255, blue: 241/255)
        case .forest:
            return Color(red: 94/255, green: 190/255, blue: 120/255)
        case .midnight:
            return Color(red: 151/255, green: 132/255, blue: 255/255)
        }
    }
    
    static func secondaryText(for theme: AppTheme) -> Color
    {
        switch theme
        {
        case .bloom:
            return Color(red: 85/255, green: 90/255, blue: 100/255)
        default:
            return Color(red: 154/255, green: 164/255, blue: 178/255)
        }
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
