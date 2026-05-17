import SwiftUI

struct CircleScreen: View
{
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    @AppStorage("displayName") private var displayName = "Tommy"
    @AppStorage("profileInitial") private var profileInitial = "T"
    @AppStorage("streak") private var currentStreak = 0
    
    // Stores saved check-in history.
    @State private var checkInHistory: [CheckInRecord] = []
    
    // Temporary local data.
    // Later this would come from a backend/database.
    var members: [CircleMember]
    {
        return [
            CircleMember(
                name: "Sarah",
                initial: "S",
                completedGoalsThisWeek: 18,
                streak: 6
            ),
            CircleMember(
                name: "John",
                initial: "J",
                completedGoalsThisWeek: 14,
                streak: 4
            ),
            CircleMember(
                name: "Ari",
                initial: "A",
                completedGoalsThisWeek: 9,
                streak: 2
            ),
            CircleMember(
                name: displayName,
                initial: profileInitial,
                completedGoalsThisWeek: weeklyCompletedGoals,
                streak: currentStreak
            )
        ]
    }
    
    // Counts all saved check-ins from this week.
    var weeklyCompletedGoals: Int
    {
        return checkInHistory.filter
        {
            isDateStringInCurrentWeek($0.dateString)
        }.count
    }
    
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
    
    var themeAccent: Color
    {
        return ThemeManager.accent(for: currentTheme)
    }
    
    var body: some View
    {
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
                        Text("Circle")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("See progress from people in your accountability circle.")
                            .font(.subheadline)
                            .foregroundColor(themeSecondaryText)
                        
                        // Weekly ranking section.
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
                            
                            ForEach(Array(sortedMembers.enumerated()), id: \.element.id)
                            { index, member in
                                CircleMemberRow(
                                    rank: index + 1,
                                    member: member
                                )
                            }
                        }
                        
                        // Recent accountability signals.
                        VStack(alignment: .leading, spacing: 10)
                        {
                            HStack
                            {
                                Text("Recent Signals")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                NavigationLink(destination: AllSignalsScreen())
                                {
                                    Text("View all")
                                        .font(.caption)
                                        .foregroundColor(themeSecondaryText)
                                }
                            }
                            
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
                        
                        // Recent activity feed.
                        VStack(alignment: .leading, spacing: 12)
                        {
                            HStack
                            {
                                Text("Recent Activity")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                NavigationLink(destination: AllActivityScreen())
                                {
                                    Text("View all")
                                        .font(.caption)
                                        .foregroundColor(themeSecondaryText)
                                }
                            }
                            
                            if members.isEmpty
                            {
                                VStack(spacing: 12)
                                {
                                    Image(systemName: "person.2")
                                        .font(.system(size: 30))
                                        .foregroundColor(themeAccent.opacity(0.8))
                                    
                                    Text("Your Circle is empty.")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("Add people to start building accountability together.")
                                        .font(.subheadline)
                                        .foregroundColor(themeSecondaryText)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                            }
                            else
                            {
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
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .onAppear
        {
            loadCheckInHistory()
        }
    }
    
    // Loads saved check-in history.
    func loadCheckInHistory()
    {
        if let data = UserDefaults.standard.data(forKey: "checkInHistory"),
           let decoded = try? JSONDecoder().decode([CheckInRecord].self, from: data)
        {
            checkInHistory = decoded
        }
    }
    
    // Checks if a saved date belongs to the current week.
    func isDateStringInCurrentWeek(_ dateString: String) -> Bool
    {
        guard let date = DateFormatter.shortDate.date(from: dateString)
        else
        {
            return false
        }
        
        return Calendar.current.isDate(
            date,
            equalTo: Date(),
            toGranularity: .weekOfYear
        )
    }
}

// Temporary Circle member model.
struct CircleMember: Identifiable
{
    let id = UUID()
    let name: String
    let initial: String
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
            Circle()
                .fill(themeAccent.opacity(0.18))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(member.initial)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(themeAccent)
                )
            
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
            
            Text("\(member.completedGoalsThisWeek) goals")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
}
