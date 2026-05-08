import SwiftUI

struct ProgressScreen: View
{
    @AppStorage("xp") private var xp = 120
    @AppStorage("streak") private var streak = 5
    
    @State private var goals: [Goal] = []
    
    var currentLevel: Int
    {
        return (xp / 100) + 1
    }
    
    var currentLevelXP: Int
    {
        return xp % 100
    }
    
    var xpNeededForNextLevel: Int
    {
        return 100
    }
    
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
                    Text("Progress")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 12)
                    {
                        Text("Level \(currentLevel)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("\(currentLevelXP) / \(xpNeededForNextLevel) XP to next level")
                            .foregroundColor(.secondaryText)
                        
                        GeometryReader
                        { geometry in
                            ZStack(alignment: .leading)
                            {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.10))
                                    .frame(height: 14)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.ascendraOrange)
                                    .frame(width: geometry.size.width * levelProgress, height: 14)
                            }
                        }
                        .frame(height: 14)
                    }
                    .padding()
                    .background(Color.ascendraCard)
                    .cornerRadius(20)
                    
                    HStack(spacing: 12)
                    {
                        ProgressStatCard(title: "Total XP", value: "\(xp)", icon: "bolt.fill")
                        ProgressStatCard(title: "Streak", value: "\(streak)", icon: "flame.fill")
                    }
                    
                    ProgressStatCard(
                        title: "Goals Completed Today",
                        value: "\(completedGoalsToday) / \(goals.count)",
                        icon: "checkmark.circle.fill"
                    )
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear
        {
            loadGoals()
        }
    }
    
    // Loads saved goals so this screen can count completed goals.
    func loadGoals()
    {
        if let data = UserDefaults.standard.data(forKey: "goals"),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data)
        {
            goals = decoded
        }
    }
}

struct ProgressStatCard: View
{
    var title: String
    var value: String
    var icon: String
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            Image(systemName: icon)
                .foregroundColor(.ascendraOrange)
                .font(.title2)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.ascendraCard)
        .cornerRadius(18)
    }
}
