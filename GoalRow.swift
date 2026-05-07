import SwiftUI

// One row in the goals list.
struct GoalRow: View
{
    // Binding lets this row edit the actual goal from ContentView
    @Binding var goal: Goal
    
    var onCheckIn: () -> Void
    var saveGoals: () -> Void
    
    // Controls the temporary +10 XP animation.
    @State private var showXP = false
    
    var body: some View
    {
        HStack(spacing: 14)
        {
            // Goal icon box.
            ZStack
            {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 56, height: 56)
                
                Image(systemName: "target")
                    .foregroundColor(.ascendraOrange)
                    .font(.title2)
            }
            
            // Goal title and frequency label.
            VStack(alignment: .leading, spacing: 4)
            {
                Text(goal.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Daily")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            ZStack
            {
                // Shows briefly after a goal is checked.
                if showXP
                {
                    Text("+10 XP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.ascendraOrange)
                        .offset(y: -34)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Check-in button.
                Button
                {
                    // Only allows XP once per day for this goal.
                    if !goal.isCheckedIn
                    {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.6))
                        {
                            goal.isCheckedIn = true
                            onCheckIn()
                            showXP = true
                        }
                        
                        saveGoals()
                        
                        // Hides the +10 XP text after delay.
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
                            .stroke(goal.isCheckedIn ? Color.ascendraOrange : Color.gray.opacity(0.6), lineWidth: 2.5)
                            .frame(width: 34, height: 34)
                        
                        if goal.isCheckedIn
                        {
                            Circle()
                                .fill(Color.ascendraOrange)
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
        .background(Color.ascendraCard)
        .cornerRadius(18)
    }
}
