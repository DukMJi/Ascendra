import SwiftUI

struct Goal: Identifiable, Codable
{
    let id: UUID
    var title: String
    var isCheckedIn: Bool
    
    init(id: UUID = UUID(), title: String, isCheckedIn: Bool = false)
    {
        self.id = id
        self.title = title
        self.isCheckedIn = isCheckedIn
    }
}

struct ContentView: View
{
    @AppStorage("xp") private var xp = 120
    @AppStorage("streak") private var streak = 5
    @AppStorage("lastOpenedDate") private var lastOpenedDate = ""
    
    @State private var goals: [Goal] = [
        Goal(title: "Study Coding"),
        Goal(title: "Gym"),
        Goal(title: "Read")
    ]
    
    @State private var showAddGoal = false
    @State private var newGoalText = ""
    
    var body: some View
    {
        ZStack
        {
            Color.ascendraBackground
                .ignoresSafeArea()
            
            ScrollView
            {
                VStack(alignment: .leading, spacing: 24)
                {
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
                    
                    VStack(alignment: .leading, spacing: 12)
                    {
                        HStack
                        {
                            Text("My Goals")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
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
                        
                        ForEach($goals)
                        { $goal in
                            GoalRow(goal: $goal, xp: $xp, saveGoals: saveGoals)
                        }
                    }
                    
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
        .onAppear
        {
            loadGoals()
            resetGoalsIfNewDay()
        }
        .sheet(isPresented: $showAddGoal)
        {
            AddGoalSheet(newGoalText: $newGoalText, goals: $goals, saveGoals: saveGoals)
        }
    }
    
    func saveGoals()
    {
        if let encoded = try? JSONEncoder().encode(goals)
        {
            UserDefaults.standard.set(encoded, forKey: "goals")
        }
    }
    
    func loadGoals()
    {
        if let data = UserDefaults.standard.data(forKey: "goals"),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data)
        {
            goals = decoded
        }
    }
    
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

struct AddGoalSheet: View
{
    @Binding var newGoalText: String
    @Binding var goals: [Goal]
    var saveGoals: () -> Void
    
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

struct GoalRow: View
{
    @Binding var goal: Goal
    @Binding var xp: Int
    
    var saveGoals: () -> Void
    
    @State private var showXP = false
    
    var body: some View
    {
        HStack(spacing: 14)
        {
            ZStack
            {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 56, height: 56)
                
                Image(systemName: "target")
                    .foregroundColor(.ascendraOrange)
                    .font(.title2)
            }
            
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
                if showXP
                {
                    Text("+10 XP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.ascendraOrange)
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
                            xp += 10
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
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(name.prefix(1)))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
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
            
            Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(success ? .ascendraOrange : .gray)
                .font(.title2)
        }
        .padding()
        .background(Color.ascendraCard)
        .cornerRadius(18)
    }
}

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

extension Color
{
    static let ascendraBackground = Color(red: 15/255, green: 17/255, blue: 21/255)
    static let ascendraCard = Color(red: 26/255, green: 31/255, blue: 39/255)
    static let ascendraOrange = Color(red: 243/255, green: 112/255, blue: 30/255)
    static let secondaryText = Color(red: 154/255, green: 164/255, blue: 178/255)
}

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
