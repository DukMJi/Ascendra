import SwiftUI

// One row in the goals list.
struct GoalRow: View
{
    // Binding lets this row edit the actual goal from ContentView.
    @Binding var goal: Goal
    
    var onCheckIn: () -> Void
    var saveGoals: () -> Void
    
    // Controls the temporary +10 XP animation.
    @State private var showXP = false
    
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
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 56, height: 56)
                
                Image(systemName: goal.icon)
                    .foregroundColor(themeAccent)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4)
            {
                Text(goal.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Daily")
                    .font(.subheadline)
                    .foregroundColor(themeSecondaryText)
            }
            
            Spacer()
            
            ZStack
            {
                if showXP
                {
                    Text("+10 XP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(themeAccent)
                        .offset(y: -34)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                Button
                {
                    if !goal.isCheckedIn
                    {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.6))
                        {
                            goal.isCheckedIn = true
                            onCheckIn()
                            showXP = true
                        }
                        
                        saveGoals()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8)
                        {
                            withAnimation(.easeOut(duration: 0.3))
                            {
                                showXP = false
                            }
                        }
                    }
                } label:
                {
                    ZStack
                    {
                        Circle()
                            .stroke(goal.isCheckedIn ? themeAccent : Color.gray.opacity(0.6), lineWidth: 2.5)
                            .frame(width: 34, height: 34)
                        
                        if goal.isCheckedIn
                        {
                            Circle()
                                .fill(themeAccent)
                                .frame(width: 34, height: 34)
                            
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                }
            }
        }
        .padding()
        .background(themeCard)
        .cornerRadius(18)
    }
}
