import SwiftUI

struct FeedRow: View
{
    let name: String
    let action: String
    let goal: String
    let note: String?
    let success: Bool
    
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
        HStack(alignment: .top, spacing: 12)
        {
            ZStack
            {
                Circle()
                    .fill(success ? themeAccent : Color.red.opacity(0.85))
                    .frame(width: 42, height: 42)
                
                Image(systemName: success ? "checkmark" : "xmark")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 4)
            {
                Text("\(name) \(action) \(goal)")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                if let note = note
                {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(themeSecondaryText)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(themeCard)
        .cornerRadius(18)
    }
}
