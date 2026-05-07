import SwiftUI

// Goal struct, Identifiable lets SwuiftUI use it inside ForEach.
// Save/load with Codable through JSON.
struct Goal: Identifiable, Codable
{
    let id: UUID
    var title: String
    var isCheckedIn: Bool
    
    // Creates new goal.
    // If no id given, automatically create new UUID.
    // New goals start unchecked by default.
    init(id: UUID = UUID(), title: String, isCheckedIn: Bool = false)
    {
        self.id = id
        self.title = title
        self.isCheckedIn = isCheckedIn
    }
}

// Main home screen.
struct ContentView: View
{
    // AppStorage saves simple values even after the app closes.
    @AppStorage("xp") private var xp = 120
    @AppStorage("streak") private var streak = 5
    @AppStorage("lastOpenedDate") private var lastOpenedDate = ""
    
    // Temp list of goals when starting app, LoadGoals() will replace.
    @State private var goals: [Goal] = [
        Goal(title: "Study Coding"),
        Goal(title: "Gym"),
        Goal(title: "Read")
    ]
    
    // Controls whether the add-goal sheet is open.
    @State private var showAddGoal = false
    
    // Stores text from user when creating new goal.
    @State private var newGoalText = ""
    
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
                            GoalRow(goal: $goal, xp: $xp, saveGoals: saveGoals)
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
            resetGoalsIfNewDay()
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

// One row in the goals list.
struct GoalRow: View
{
    // Binding lets hits row edit the actual goal from ContentView
    @Binding var goal: Goal
    
    // Binding lets this row increase XP in ContentView.
    @Binding var xp: Int
    
    // Function used to save the updated check state.
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
                            xp += 10
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

// One row in the feed preview.
struct FeedRow: View
{
    var name: String
    var action: String
    var goal: String
    var note: String?
    var success: Bool
    
    var body: some View
    {
        HStack(spacing: 14)
        {
            // Simple profile circle with the user's first initial.
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(name.prefix(1)))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // Feed message and optinoal note.
            VStack(alignment: .leading, spacing: 4)
            {
                Text("\(name) \(action) \(goal)")
                    .foregroundColor(.white)
                
                if let note = note
                {
                    Text("“\(note)”")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
            
            // Shows success or missed status.
            Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(success ? .ascendraOrange : .gray)
                .font(.title2)
        }
        .padding()
        .background(Color.ascendraCard)
        .cornerRadius(18)
    }
}

// Small card used for XP and streak in header.
struct StatCard: View
{
    var icon: String
    var value: String
    var label: String
    
    var body: some View
    {
        VStack(spacing: 2)
        {
            Image(systemName: icon)
                .foregroundColor(.ascendraOrange)
            
            Text(value)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondaryText)
        }
        .frame(width: 62, height: 62)
        .background(Color.ascendraCard)
        .cornerRadius(16)
    }
}

// Custom App theme colors.
extension Color
{
    static let ascendraBackground = Color(red: 15/255, green: 17/255, blue: 21/255)
    static let ascendraCard = Color(red: 26/255, green: 31/255, blue: 39/255)
    static let ascendraOrange = Color(red: 243/255, green: 112/255, blue: 30/255)
    static let secondaryText = Color(red: 154/255, green: 164/255, blue: 178/255)
}

// Shared date formatter used for checking whether a new day has started.
extension DateFormatter
{
    static let shortDate: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

#Preview
{
    ContentView()
}
