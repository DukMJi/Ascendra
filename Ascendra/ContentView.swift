import SwiftUI

// Main home screen.
struct ContentView: View
{
    // AppStorage saves simple values even after the app closes.
    @AppStorage("xp") private var xp = 120
    @AppStorage("streak") private var streak = 5
    @AppStorage("lastOpenedDate") private var lastOpenedDate = ""
    @AppStorage("lastCheckInDate") private var lastCheckInDate = ""
    
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
    
    var body: some View
    {
        ZStack
        {
            // Main app background.
            Color.ascendraBackground
                .ignoresSafeArea()
            
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
                            .foregroundColor(.secondaryText)
                        
                        Text("“The secret of getting ahead is getting started.”")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("— Mark Twain")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.ascendraCard)
                    .cornerRadius(20)
                    
                    // Level progress card.
                    VStack(alignment: .leading, spacing: 12)
                    {
                        HStack
                        {
                            Text("Level \(currentLevel)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(currentLevelXP) / \(xpNeededForNextLevel) XP")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                        }
                        
                        // Visual progress bar for current level.
                        GeometryReader
                        { geometry in
                            ZStack(alignment: .leading)
                            {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.10))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.ascendraOrange)
                                    .frame(width: geometry.size.width * levelProgress, height: 12)
                            }
                        }
                        .frame(height: 12)
                        
                        Text("Keep checking in to unlock more rewards.")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.ascendraCard)
                    .cornerRadius(20)
                    
                    // Shows the user's most recently earned badge.
                    if let badge = recentBadge
                    {
                        VStack(alignment: .leading, spacing: 12)
                        {
                            HStack(spacing: 14)
                            {
                                Image(systemName: badge.icon)
                                    .font(.largeTitle)
                                    .foregroundColor(.ascendraOrange)
                                
                                VStack(alignment: .leading, spacing: 4)
                                {
                                    Text("New Badge Earned")
                                        .font(.caption)
                                        .foregroundColor(.secondaryText)
                                    
                                    Text(badge.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text(badge.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondaryText)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.ascendraCard)
                        .cornerRadius(20)
                    }
                    
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
                                    .foregroundColor(.ascendraOrange)
                                    .font(.title2)
                            }
                        }
                        
                        // Creates one GoalRow for every goal in the goals array.
                        // $ symbol passes binding so GoalRow can edit goal.
                        ForEach($goals)
                        { $goal in
                            GoalRow(goal: $goal, onCheckIn: handleGoalCheckIn, saveGoals: saveGoals)
                        }
                    }
                    
                    // Preview of friend activity w/ temp data.
                    VStack(alignment: .leading, spacing: 12)
                    {
                        HStack
                        {
                            Text("Feed Preview")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("View Full Feed")
                                .foregroundColor(.ascendraOrange)
                        }
                        
                        FeedRow(name: "John", action: "checked in on", goal: "Gym", note: "Leg day done", success: true)
                        FeedRow(name: "Sarah", action: "missed", goal: "Reading", note: nil, success: false)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
        }
        // Runs when screen first appears.
        .onAppear
        {
            loadGoals()
            loadBadges()
            resetGoalsIfNewDay()
            checkForMissedStreak()
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
                goals[index].isCheckedIn = false
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
    
    // Function passed in from ContentView so this sheet can save goals.
    var saveGoals: () -> Void
    
    // Allows this sheet to close itself.
    @Environment(\.dismiss) var dismiss
    
    var body: some View
    {
        ZStack
        {
            Color.ascendraBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20)
            {
                Text("New Goal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                TextField("Enter goal...", text: $newGoalText)
                    .padding()
                    .background(Color.ascendraCard)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                
                // Adds the goal if the text is not empty.
                Button
                {
                    let trimmedGoal = newGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !trimmedGoal.isEmpty
                    {
                        goals.append(Goal(title: trimmedGoal))
                        saveGoals()
                        newGoalText = ""
                        dismiss()
                    }
                } label:
                {
                    Text("Add Goal")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.ascendraOrange)
                        .cornerRadius(14)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview
{
    ContentView()
}
