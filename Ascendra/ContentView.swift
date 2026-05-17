import SwiftUI

// Main home screen.
struct ContentView: View
{
    // AppStorage saves simple values even after the app closes.
    @AppStorage("xp") private var xp = 120
    @AppStorage("streak") private var streak = 5
    @AppStorage("lastOpenedDate") private var lastOpenedDate = ""
    @AppStorage("lastCheckInDate") private var lastCheckInDate = ""
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    
    // Temp list of goals when starting app, loadGoals() will replace.
    @State private var goals: [Goal] = [
        Goal(title: "Study Coding"),
        Goal(title: "Gym"),
        Goal(title: "Read")
    ]
    
    // Controls whether the add-goal sheet is open.
    @State private var showAddGoal = false
    
    // Stores text from user when creating new goal.
    @State private var newGoalText = ""
    
    // Stores most recent earned badge.
    @State private var recentBadge: Badge? = nil

    // Stores all earned badges.
    @State private var earnedBadges: [Badge] = []
    
    @State private var checkInHistory: [CheckInRecord] = []
    
    // Calculates user's current level based on total XP.
    var currentLevel: Int
    {
        return (xp / 100) + 1
    }

    // Calculates how much XP user has earned inside current level.
    var currentLevelXP: Int
    {
        return xp % 100
    }

    // Calculates XP needed to reach the next level.
    var xpNeededForNextLevel: Int
    {
        return 100
    }

    // Converts current level XP into a progress value between 0.0 and 1.0.
    var levelProgress: Double
    {
        return Double(currentLevelXP) / Double(xpNeededForNextLevel)
    }
    
    var completedGoalsToday: Int
    {
        return goals.filter
        {
            $0.isCheckedIn
        }.count
    }

    var dailyGoalProgress: Double
    {
        if goals.count == 0
        {
            return 0.0
        }
        
        return Double(completedGoalsToday) / Double(goals.count)
    }
    
    // Converts saved theme string into AppTheme.
    var currentTheme: AppTheme
    {
        return AppTheme(rawValue: selectedTheme) ?? .core
    }

    // Current theme background color.
    var themeBackground: Color
    {
        return ThemeManager.background(for: currentTheme)
    }

    // Current theme card color.
    var themeCard: Color
    {
        return ThemeManager.card(for: currentTheme)
    }

    // Current theme accent color.
    var themeAccent: Color
    {
        return ThemeManager.accent(for: currentTheme)
    }

    // Current theme secondary text color.
    var themeSecondaryText: Color
    {
        return ThemeManager.secondaryText(for: currentTheme)
    }
    
    var body: some View
    {
        ZStack
        {
            // Main app background.
            themeBackground
                .ignoresSafeArea()
            
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture
                {
                    NotificationCenter.default.post(name: NSNotification.Name("CloseGoalSliders"), object: nil)
                }
            
            ScrollView
            {
                VStack(alignment: .leading, spacing: 24)
                {
                    // Header section with app name, streak, and XP.
                    HStack
                    {
                        Text("Ascendra")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        StatCard(icon: "flame.fill", value: "\(streak)", label: "Streak")
                        StatCard(icon: "bolt.fill", value: "\(xp)", label: "XP")
                    }
                    
                    // Daily quote card.
                    VStack(alignment: .leading, spacing: 12)
                    {
                        Text("Daily Thought")
                            .font(.caption)
                            .foregroundColor(themeSecondaryText)
                        
                        Text("“The secret of getting ahead is getting started.”")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("— Mark Twain")
                            .font(.subheadline)
                            .foregroundColor(themeSecondaryText)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeCard)
                    .cornerRadius(20)
                    
                    DailyProgressRing(
                        completedGoals: completedGoalsToday,
                        totalGoals: goals.count,
                        progress: dailyGoalProgress
                    )
                    
                    // Goals section.
                    VStack(alignment: .leading, spacing: 12)
                    {
                        HStack
                        {
                            Text("My Goals")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Opens the sheet where the user can add new goals.
                            Button
                            {
                                showAddGoal = true
                            } label:
                            {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(themeAccent)
                                    .font(.title2)
                            }
                        }
                        
                        // Shows an empty state when no goals exist yet.
                        if goals.isEmpty
                        {
                            VStack(spacing: 14)
                            {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 34))
                                    .foregroundColor(themeAccent.opacity(0.8))
                                
                                Text("Start building momentum.")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Add your first goal to begin tracking consistency.")
                                    .font(.subheadline)
                                    .foregroundColor(themeSecondaryText)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 50)
                        }
                        else
                        {
                            // Creates one GoalRow for every goal in the goals array.
                            // $ symbol passes binding so GoalRow can edit goal.
                            ForEach($goals)
                            { $goal in
                                GoalRow(
                                    goal: $goal,
                                    onCheckIn:
                                    {
                                        handleGoalCheckIn()
                                        addCheckInRecord(for: goal)
                                    },
                                    saveGoals: saveGoals,
                                    onDelete:
                                    {
                                        deleteGoal(goal)
                                    }
                                )
                            }
                        }
                    }

                    Spacer(minLength: 30)
                }
                .padding()
            }
            
            .simultaneousGesture(
                TapGesture()
                    .onEnded
                    {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("CloseGoalSliders"),
                            object: nil
                        )
                    }
            )
        }
        // Runs when screen first appears.
        .onAppear
        {
            loadGoals()
            loadBadges()
            resetGoalsIfNewDay()
            checkForMissedStreak()
            loadCheckInHistory()
        }
        // Shows the add-goal sheet.
        .sheet(isPresented: $showAddGoal)
        {
            AddGoalSheet(newGoalText: $newGoalText, goals: $goals, saveGoals: saveGoals)
        }
    }
    
    // Saves the goals array to UserDefaults as JSON data.
    func saveGoals()
    {
        if let encoded = try? JSONEncoder().encode(goals)
        {
            UserDefaults.standard.set(encoded, forKey: "goals")
        }
    }
    
    func deleteGoal(_ goal: Goal)
    {
        goals.removeAll
        {
            $0.id == goal.id
        }
        
        saveGoals()
    }
    
    // Loads data goals from UserDefaults.
    // If no saved goals exist, starter goals stay on screen.
    func loadGoals()
    {
        if let data = UserDefaults.standard.data(forKey: "goals"),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data)
        {
            goals = decoded
        }
    }
    
    func saveCheckInHistory()
    {
        if let encoded = try? JSONEncoder().encode(checkInHistory)
        {
            UserDefaults.standard.set(encoded, forKey: "checkInHistory")
        }
    }

    func loadCheckInHistory()
    {
        if let data = UserDefaults.standard.data(forKey: "checkInHistory"),
           let decoded = try? JSONDecoder().decode([CheckInRecord].self, from: data)
        {
            checkInHistory = decoded
        }
    }

    func addCheckInRecord(for goal: Goal)
    {
        let today = DateFormatter.shortDate.string(from: Date())
        
        let newRecord = CheckInRecord(
            goalTitle: goal.title,
            goalIcon: goal.icon,
            dateString: today
        )
        
        checkInHistory.append(newRecord)
        saveCheckInHistory()
    }
    
    // Saves earned badges to UserDefaults as JSON data.
    func saveBadges()
    {
        if let encoded = try? JSONEncoder().encode(earnedBadges)
        {
            UserDefaults.standard.set(encoded, forKey: "earnedBadges")
        }
    }

    // Loads earned badges from UserDefaults.
    func loadBadges()
    {
        if let data = UserDefaults.standard.data(forKey: "earnedBadges"),
           let decoded = try? JSONDecoder().decode([Badge].self, from: data)
        {
            earnedBadges = decoded
            recentBadge = earnedBadges.last
        }
    }
    
    // Checks whether the app is being opened on a new day.
    // If new day, all goals are unchecked.
    func resetGoalsIfNewDay()
    {
        let today = DateFormatter.shortDate.string(from: Date())
        
        if lastOpenedDate.isEmpty
        {
            lastOpenedDate = today
            return
        }
        
        if lastOpenedDate != today
        {
            for index in goals.indices
            {
                // Reset visual check state.
                goals[index].isCheckedIn = false
                
                // Allow rewards/check-ins again tomorrow.
                goals[index].hasCompletedToday = false
            }
            
            lastOpenedDate = today
            saveGoals()
        }
    }
    
    func handleGoalCheckIn()
    {
        xp += 10
        updateStreak()
        checkForBadges()
    }

    func updateStreak()
    {
        let today = DateFormatter.shortDate.string(from: Date())
        
        if lastCheckInDate == today
        {
            return
        }
        
        if lastCheckInDate.isEmpty
        {
            streak = 1
        }
        else if isYesterday(lastCheckInDate)
        {
            streak += 1
        }
        else
        {
            streak = 1
        }
        
        lastCheckInDate = today
    }

    func checkForMissedStreak()
    {
        if lastCheckInDate.isEmpty
        {
            return
        }
        
        let today = DateFormatter.shortDate.string(from: Date())
        
        if lastCheckInDate == today
        {
            return
        }
        
        if !isYesterday(lastCheckInDate)
        {
            streak = 0
        }
    }

    func isYesterday(_ dateString: String) -> Bool
    {
        guard let savedDate = DateFormatter.shortDate.date(from: dateString)
        else
        {
            return false
        }
        
        let calendar = Calendar.current
        
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())
        else
        {
            return false
        }
        
        return calendar.isDate(savedDate, inSameDayAs: yesterday)
    }
    
    // Checks if user has earned any new badges.
    func checkForBadges()
    {
        if xp >= 10 && !hasBadge(named: "First Check-In")
        {
            unlockBadge(
                title: "First Check-In",
                description: "Completed your first goal.",
                icon: "star.fill"
            )
        }
        
        if xp >= 100 && !hasBadge(named: "100 XP")
        {
            unlockBadge(
                title: "100 XP",
                description: "Reached 100 total XP.",
                icon: "bolt.fill"
            )
        }
        
        if streak >= 3 && !hasBadge(named: "3-Day Streak")
        {
            unlockBadge(
                title: "3-Day Streak",
                description: "Stayed consistent for 3 days.",
                icon: "flame.fill"
            )
        }
    }

    // Creates and stores newly earned badge.
    func unlockBadge(title: String, description: String, icon: String)
    {
        let newBadge = Badge(
            title: title,
            description: description,
            icon: icon
        )
        
        earnedBadges.append(newBadge)
        recentBadge = newBadge
        saveBadges()
    }

    // Checks whether user already owns a badge.
    func hasBadge(named title: String) -> Bool
    {
        return earnedBadges.contains
        {
            $0.title == title
        }
    }
    
}

// Sheet that lets the user create a new goal.
struct AddGoalSheet: View
{
    @Binding var newGoalText: String
    @Binding var goals: [Goal]
    
    @State private var selectedIcon = "target"

    let goalIcons = [
        "target",
        "book.fill",
        "dumbbell.fill",
        "heart.fill",
        "moon.fill",
        "briefcase.fill",
        "figure.run",
        "fork.knife"
    ]

    let iconColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Function passed in from ContentView so this sheet can save goals.
    var saveGoals: () -> Void
    
    // Allows this sheet to close itself.
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    
    var currentTheme: AppTheme
    {
        return AppTheme(rawValue: selectedTheme) ?? .core
    }
    
    var themeBackground: Color
    {
        return ThemeManager.background(for: currentTheme)
    }
    
    var themeCard: Color
    {
        return ThemeManager.card(for: currentTheme)
    }
    
    var themeAccent: Color
    {
        return ThemeManager.accent(for: currentTheme)
    }
    
    var body: some View
    {
        ZStack
        {
            themeBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20)
            {
                Text("New Goal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                TextField("Enter goal...", text: $newGoalText)
                    .padding()
                    .background(themeCard)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                
                Text("Choose Icon")
                    .font(.headline)
                    .foregroundColor(.white)

                LazyVGrid(columns: iconColumns, spacing: 12)
                {
                    ForEach(goalIcons, id: \.self)
                    { icon in
                        Button
                        {
                            selectedIcon = icon
                        } label:
                        {
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(selectedIcon == icon ? .white : themeAccent)
                                .frame(width: 52, height: 52)
                                .background(selectedIcon == icon ? themeAccent : themeCard)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedIcon == icon ? themeAccent : Color.white.opacity(0.10), lineWidth: 2)
                                )
                        }
                    }
                }
                
                // Adds the goal if the text is not empty.
                Button
                {
                    let trimmedGoal = newGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !trimmedGoal.isEmpty
                    {
                        goals.append(Goal(title: trimmedGoal, icon: selectedIcon))
                        saveGoals()
                        newGoalText = ""
                        selectedIcon = "target"
                        dismiss()
                    }
                } label:
                {
                    Text("Add Goal")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeAccent)
                        .cornerRadius(14)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct DailyProgressRing: View
{
    var progressMessage: String
    {
        if totalGoals == 0
        {
            return "Add a goal to begin."
        }
        
        if completedGoals == totalGoals
        {
            return "All goals complete."
        }
        
        if completedGoals == 0
        {
            return "Start with one check-in."
        }
        
        return "Keep the streak alive."
    }
    
    var completedGoals: Int
    var totalGoals: Int
    var progress: Double
    
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
        HStack(spacing: 20)
        {
            ZStack
            {
                Circle()
                    .stroke(Color.white.opacity(0.10), lineWidth: 14)
                    .frame(width: 110, height: 110)
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(themeAccent, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: progress)
                
                VStack(spacing: 2)
                {
                    Text("\(Int(progress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("\(completedGoals)/\(totalGoals)")
                        .font(.caption)
                        .foregroundColor(themeSecondaryText)
                }
            }
            
            VStack(alignment: .leading, spacing: 6)
            {
                Text("Today’s Progress")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(completedGoals) of \(totalGoals) goals checked in")
                    .font(.subheadline)
                    .foregroundColor(themeSecondaryText)
                
                Text(progressMessage)
                    .font(.caption)
                    .foregroundColor(themeAccent)

                if completedGoals == totalGoals && totalGoals > 0
                {
                    Text("Daily Complete")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(themeAccent)
                        .cornerRadius(20)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(themeCard)
        .cornerRadius(20)
    }
}

#Preview
{
    ContentView()
}
