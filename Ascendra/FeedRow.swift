import SwiftUI

struct FeedRow: View
{
    let name: String
    let action: String
    let goal: String
    let note: String?
    let success: Bool
    
    // Small support circle state.
    @State private var isSupported = false
    
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
        VStack(spacing: 0)
        {
            HStack(alignment: .center, spacing: 12)
            {
                // Small activity status circle.
                Circle()
                    .fill(success ? themeAccent : Color.red.opacity(0.85))
                    .frame(width: 10, height: 10)
                
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
                
                // Small support acknowledgment circle.
                Button
                {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.65))
                    {
                        isSupported.toggle()
                    }
                } label:
                {
                    Circle()
                        .fill(isSupported ? themeAccent : Color.clear)
                        .frame(width: 17, height: 17)
                        .overlay(
                            Circle()
                                .stroke(themeAccent, lineWidth: 2)
                        )
                        .scaleEffect(isSupported ? 1.12 : 1.0)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 10)
            
            // Subtle divider.
            Divider()
                .overlay(Color.white.opacity(0.06))
        }
    }
}
