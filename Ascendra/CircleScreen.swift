import SwiftUI

struct CircleScreen: View
{
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    
    // Temporary local data.
    // Later this would come from a backend/database.
    let members: [CircleMember] = [
        CircleMember(name: "Sarah", completedGoalsThisWeek: 18, streak: 6),
        CircleMember(name: "John", completedGoalsThisWeek: 14, streak: 4),
        CircleMember(name: "Ari", completedGoalsThisWeek: 9, streak: 2),
        CircleMember(name: "Tommy", completedGoalsThisWeek: 7, streak: 3)
    ]
    
    // Sort members by completed goals descending.
    var sortedMembers: [CircleMember]
    {
        return members.sorted
        {
            $0.completedGoalsThisWeek > $1.completedGoalsThisWeek
        }
    }
    
    // Current selected theme.
    var currentTheme: AppTheme
    {
        return AppTheme(rawValue: selectedTheme) ?? .core
    }
    
    // Theme colors.
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
        // NavigationStack allows screen navigation.
        NavigationStack
        {
            ZStack
            {
                themeBackground
                    .ignoresSafeArea()
                
                ScrollView
                {
                    VStack(alignment: .leading, spacing: 24)
                    {
                        // Main screen title.
                        Text("Circle")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("See progress from people in your accountability circle.")
                            .font(.subheadline)
                            .foregroundColor(themeSecondaryText)
                        
                        // Weekly member ranking.
                        VStack(alignment: .leading, spacing: 12)
                        {
                            HStack
                            {
                                Text("Weekly Momentum")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("Resets weekly")
                                    .font(.caption)
                                    .foregroundColor(themeSecondaryText)
                            }
                            
                            // Displays sorted member rows.
                            ForEach(Array(sortedMembers.enumerated()), id: \.element.id)
                            { index, member in
                                CircleMemberRow(
                                    rank: index + 1,
                                    member: member
                                )
                            }
                        }
                        
                        // Recent lightweight accountability signals.
                        VStack(alignment: .leading, spacing: 10)
                        {
                            HStack
                            {
                                Text("Recent Signals")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // Opens full signals history screen.
                                NavigationLink(destination: AllSignalsScreen())
                                {
                                    Text("View all")
                                        .font(.caption)
                                        .foregroundColor(themeSecondaryText)
                                }
                            }
                            
                            // Only showing 3 recent signals.
                            SignalRow(
                                icon: "eye.fill",
                                message: "Ari noticed your consistency."
                            )
                            
                            SignalRow(
                                icon: "circle.fill",
                                message: "Supported by someone in your Circle."
                            )
                            
                            SignalRow(
                                icon: "flame.fill",
                                message: "John noticed your 3-day streak."
                            )
                        }
                        
                        // Recent Circle activity feed.
                        VStack(alignment: .leading, spacing: 12)
                        {
                            HStack
                            {
                                Text("Recent Activity")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // Opens full activity history screen.
                                NavigationLink(destination: AllActivityScreen())
                                {
                                    Text("View all")
                                        .font(.caption)
                                        .foregroundColor(themeSecondaryText)
                                }
                            }
                            
                            // Only showing 3 recent activity items.
                            FeedRow(
                                name: "John",
                                action: "checked in on",
                                goal: "Gym",
                                note: "Leg day done",
                                success: true
                            )
                            
                            FeedRow(
                                name: "Sarah",
                                action: "checked in on",
                                goal: "Reading",
                                note: "Finished 10 pages",
                                success: true
                            )
                            
                            FeedRow(
                                name: "Ari",
                                action: "missed",
                                goal: "Study",
                                note: nil,
                                success: false
                            )
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

// Temporary Circle member model.
struct CircleMember: Identifiable
{
    let id = UUID()
    let name: String
    let completedGoalsThisWeek: Int
    let streak: Int
}

// Lightweight ranking row.
struct CircleMemberRow: View
{
    let rank: Int
    let member: CircleMember
    
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
        HStack(spacing: 14)
        {
            // User initial circle.
            Circle()
                .fill(themeAccent.opacity(0.18))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(member.name.prefix(1)))
                        .fontWeight(.bold)
                        .foregroundColor(themeAccent)
                )
            
            // Member info.
            VStack(alignment: .leading, spacing: 3)
            {
                Text(member.name)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("\(member.streak)-day streak")
                    .font(.caption)
                    .foregroundColor(themeSecondaryText)
            }
            
            Spacer()
            
            // Weekly goal count.
            Text("\(member.completedGoalsThisWeek) goals")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
}
