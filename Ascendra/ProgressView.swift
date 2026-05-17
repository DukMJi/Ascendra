import SwiftUI

struct ProgressScreen: View
{
    @AppStorage("xp") private var xp = 120
    @AppStorage("streak") private var streak = 5
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    
    @State private var goals: [Goal] = []
    
    // Saved check-in history.
    @State private var checkInHistory: [CheckInRecord] = []
    
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
    
    var themeSecondaryText: Color
    {
        return ThemeManager.secondaryText(for: currentTheme)
    }
    
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
    
    // Counts check-ins from current week.
    var weeklyCompletedGoals: Int
    {
        return checkInHistory.filter
        {
            isDateStringInCurrentWeek($0.dateString)
        }.count
    }
    
    // Finds most completed goal this week.
    var mostConsistentGoal: String
    {
        let weeklyRecords = checkInHistory.filter
        {
            isDateStringInCurrentWeek($0.dateString)
        }
        
        if weeklyRecords.isEmpty
        {
            return "None yet"
        }
        
        var counts: [String: Int] = [:]
        
        for record in weeklyRecords
        {
            counts[record.goalTitle, default: 0] += 1
        }
        
        return counts.max
        {
            $0.value < $1.value
        }?.key ?? "None yet"
    }
    
    // Creates daily counts for current week.
    var weeklyDailyCounts: [DailyGoalCount]
    {
        let calendar = Calendar.current
        let today = Date()
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today)
        else
        {
            return []
        }
        
        var counts: [DailyGoalCount] = []
        
        for dayIndex in 0..<7
        {
            guard let dayDate = calendar.date(byAdding: .day, value: dayIndex, to: weekInterval.start)
            else
            {
                continue
            }
            
            let dayString = DateFormatter.shortDate.string(from: dayDate)
            
            let completedCount = checkInHistory.filter
            {
                $0.dateString == dayString
            }.count
            
            let weekdayLetter = DateFormatter.weekdayLetter.string(from: dayDate)
            
            counts.append(
                DailyGoalCount(
                    dayLabel: weekdayLetter,
                    count: completedCount,
                    isToday: calendar.isDate(dayDate, inSameDayAs: today)
                )
            )
        }
        
        return counts
    }
    
    // Creates the last 30 days for monthly heatmap.
    var monthlyHeatmapDays: [MonthlyHeatmapDay]
    {
        let calendar = Calendar.current
        let today = Date()
        var days: [MonthlyHeatmapDay] = []
        
        for offset in stride(from: 29, through: 0, by: -1)
        {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today)
            else
            {
                continue
            }
            
            let dateString = DateFormatter.shortDate.string(from: date)
            
            let completedCount = checkInHistory.filter
            {
                $0.dateString == dateString
            }.count
            
            days.append(
                MonthlyHeatmapDay(
                    dateString: dateString,
                    count: completedCount,
                    isToday: calendar.isDate(date, inSameDayAs: today)
                )
            )
        }
        
        return days
    }
    
    // Counts which goals were checked in most during the current week.
    var goalDistribution: [GoalDistributionItem]
    {
        let weeklyRecords = checkInHistory.filter
        {
            isDateStringInCurrentWeek($0.dateString)
        }
        
        var counts: [String: Int] = [:]
        var icons: [String: String] = [:]
        
        for record in weeklyRecords
        {
            counts[record.goalTitle, default: 0] += 1
            icons[record.goalTitle] = record.goalIcon
        }
        
        return counts.map
        { title, count in
            GoalDistributionItem(
                title: title,
                icon: icons[title] ?? "target",
                count: count
            )
        }
        .sorted
        {
            $0.count > $1.count
        }
    }
    
    var body: some View
    {
        ZStack
        {
            themeBackground
                .ignoresSafeArea()
            
            ScrollView
            {
                VStack(alignment: .leading, spacing: 24)
                {
                    Text("Progress")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
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
                            
                            Text("\(xp) XP")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(themeAccent)
                        }
                        
                        GeometryReader
                        { geometry in
                            ZStack(alignment: .leading)
                            {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.10))
                                    .frame(height: 14)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(themeAccent)
                                    .frame(width: geometry.size.width * levelProgress, height: 14)
                            }
                        }
                        .frame(height: 14)
                        
                        Text("\(currentLevelXP) / \(xpNeededForNextLevel) XP to next level")
                            .font(.caption)
                            .foregroundColor(themeSecondaryText)
                    }
                    .padding()
                    .background(themeCard)
                    .cornerRadius(20)
                    
                    WeeklyBarChartCard(dailyCounts: weeklyDailyCounts)
                    
                    MonthlyHeatmapCard(days: monthlyHeatmapDays)
                    
                    GoalDistributionCard(items: goalDistribution)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear
        {
            loadGoals()
            loadCheckInHistory()
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
    
    func loadCheckInHistory()
    {
        if let data = UserDefaults.standard.data(forKey: "checkInHistory"),
           let decoded = try? JSONDecoder().decode([CheckInRecord].self, from: data)
        {
            checkInHistory = decoded
        }
    }
    
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

// Data for weekly bar chart.
struct DailyGoalCount: Identifiable
{
    let id = UUID()
    let dayLabel: String
    let count: Int
    let isToday: Bool
}

// Data for monthly heatmap.
struct MonthlyHeatmapDay: Identifiable
{
    let id = UUID()
    let dateString: String
    let count: Int
    let isToday: Bool
}

// Data for goal distribution.
struct GoalDistributionItem: Identifiable
{
    let id = UUID()
    let title: String
    let icon: String
    let count: Int
}

struct WeeklyBarChartCard: View
{
    var dailyCounts: [DailyGoalCount]
    
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
    
    var maxCount: Int
    {
        return max(dailyCounts.map { $0.count }.max() ?? 1, 1)
    }
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            Text("Weekly Momentum")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(alignment: .bottom, spacing: 12)
            {
                ForEach(dailyCounts)
                { day in
                    VStack(spacing: 8)
                    {
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(day.isToday ? themeAccent : themeAccent.opacity(0.45))
                            .frame(
                                width: 24,
                                height: CGFloat(max(day.count, 1)) / CGFloat(maxCount) * 90
                            )
                        
                        Text(day.dayLabel)
                            .font(.caption)
                            .foregroundColor(day.isToday ? themeAccent : themeSecondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 130)
        }
        .padding()
        .background(themeCard)
        .cornerRadius(20)
    }
}

struct MonthlyHeatmapCard: View
{
    var days: [MonthlyHeatmapDay]
    
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 10)
    
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
    
    func opacityForCount(_ count: Int) -> Double
    {
        if count == 0
        {
            return 0.12
        }
        else if count == 1
        {
            return 0.35
        }
        else if count == 2
        {
            return 0.60
        }
        else
        {
            return 1.0
        }
    }
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 14)
        {
            Text("Monthly Consistency")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: columns, spacing: 6)
            {
                ForEach(days)
                { day in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(themeAccent.opacity(opacityForCount(day.count)))
                        .frame(height: 18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(day.isToday ? themeAccent : Color.clear, lineWidth: 1.5)
                        )
                }
            }
        }
        .padding()
        .background(themeCard)
        .cornerRadius(20)
    }
}

struct GoalDistributionCard: View
{
    var items: [GoalDistributionItem]
    
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
    
    var totalCount: Int
    {
        return max(items.map { $0.count }.reduce(0, +), 1)
    }
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 14)
        {
            Text("Goal Distribution")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if items.isEmpty
            {
                Text("Check in goals to build your distribution.")
                    .font(.subheadline)
                    .foregroundColor(themeSecondaryText)
            }
            else
            {
                ForEach(items.prefix(5))
                { item in
                    VStack(alignment: .leading, spacing: 6)
                    {
                        HStack
                        {
                            Image(systemName: item.icon)
                                .foregroundColor(themeAccent)
                                .frame(width: 24)
                            
                            Text(item.title)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(Int((Double(item.count) / Double(totalCount)) * 100))%")
                                .foregroundColor(themeSecondaryText)
                        }
                        
                        GeometryReader
                        { geometry in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(themeAccent)
                                        .frame(
                                            width: geometry.size.width * (Double(item.count) / Double(totalCount))
                                        ),
                                    alignment: .leading
                                )
                        }
                        .frame(height: 8)
                    }
                }
            }
            
            Text("Percentages based on this week's check-ins.")
                .font(.caption)
                .foregroundColor(themeSecondaryText)
            
        }
        .padding()
        .background(themeCard)
        .cornerRadius(20)
    }
}
