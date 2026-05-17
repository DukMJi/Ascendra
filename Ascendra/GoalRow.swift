import SwiftUI

// One row in the goals list.
struct GoalRow: View
{
    @Binding var goal: Goal
    
    var onCheckIn: () -> Void
    var saveGoals: () -> Void
    var onDelete: () -> Void
    
    @State private var showXP = false
    @State private var showEditSheet = false
    @State private var editedTitle = ""
    @State private var editedIcon = "target"
    @State private var showDeleteConfirmation = false
    
    @State private var dragOffset: CGFloat = 0
    @State private var revealedAction: String? = nil
    
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    
    let revealWidth: CGFloat = 105
    
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
        ZStack
        {
            // Background edit/delete reveal layer.
            HStack
            {
                if dragOffset > 0 || revealedAction == "edit"
                {
                    Button
                    {
                        editedTitle = goal.title
                        editedIcon = goal.icon
                        showEditSheet = true
                        
                        withAnimation(.spring())
                        {
                            dragOffset = 0
                            revealedAction = nil
                        }
                    } label:
                    {
                        Text("Edit")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: revealWidth, height: 78)
                            .background(themeAccent)
                            .cornerRadius(18)
                    }
                    .opacity(min(abs(dragOffset) / revealWidth, 1.0))
                    
                    Spacer()
                }
                
                Spacer()
                
                if dragOffset < 0 || revealedAction == "delete"
                {
                    Button
                    {
                        showDeleteConfirmation = true
                    } label:
                    {
                        Text("Delete")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: revealWidth, height: 78)
                            .background(Color.red.opacity(0.85))
                            .cornerRadius(18)
                    }
                    .opacity(min(abs(dragOffset) / revealWidth, 1.0))
                }
            }
            
            // Foreground goal row.
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
                    }
                    
                    Button
                    {
                        // If row is slid open, close it first.
                        if revealedAction != nil
                        {
                            withAnimation(.spring())
                            {
                                dragOffset = 0
                                revealedAction = nil
                            }
                            
                            return
                        }
                        
                        // Tapping checked goal visually unchecks it.
                        if goal.isCheckedIn
                        {
                            goal.isCheckedIn = false
                        }
                        else
                        {
                            goal.isCheckedIn = true
                            
                            // Award XP/history only once per day.
                            if !goal.hasCompletedToday
                            {
                                goal.hasCompletedToday = true
                                
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.6))
                                {
                                    showXP = true
                                }
                                
                                onCheckIn()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8)
                                {
                                    withAnimation(.easeOut(duration: 0.3))
                                    {
                                        showXP = false
                                    }
                                }
                            }
                        }
                        
                        saveGoals()
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
            .offset(x: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged
                    { value in
                        let translation = value.translation.width
                        
                        if translation > 0
                        {
                            dragOffset = min(translation, revealWidth)
                        }
                        else
                        {
                            dragOffset = max(translation, -revealWidth)
                        }
                    }
                    .onEnded
                    { value in
                        withAnimation(.spring())
                        {
                            if value.translation.width > 70
                            {
                                dragOffset = revealWidth
                                revealedAction = "edit"
                            }
                            else if value.translation.width < -70
                            {
                                dragOffset = -revealWidth
                                revealedAction = "delete"
                            }
                            else
                            {
                                dragOffset = 0
                                revealedAction = nil
                            }
                        }
                    }
            )
            .onTapGesture
            {
                if revealedAction != nil
                {
                    withAnimation(.spring())
                    {
                        dragOffset = 0
                        revealedAction = nil
                    }
                }
            }
            
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CloseGoalSliders")))
            { _ in
                if revealedAction != nil
                {
                    withAnimation(.spring())
                    {
                        dragOffset = 0
                        revealedAction = nil
                    }
                }
            }
        }
        .sheet(isPresented: $showEditSheet)
        {
            ZStack
            {
                ThemeManager.background(for: currentTheme)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20)
                {
                    Text("Edit Goal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    TextField("Goal title", text: $editedTitle)
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
                                editedIcon = icon
                            } label:
                            {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(editedIcon == icon ? .white : themeAccent)
                                    .frame(width: 52, height: 52)
                                    .background(editedIcon == icon ? themeAccent : themeCard)
                                    .cornerRadius(14)
                            }
                        }
                    }
                    
                    Button
                    {
                        let trimmedTitle = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !trimmedTitle.isEmpty
                        {
                            goal.title = trimmedTitle
                            goal.icon = editedIcon
                            saveGoals()
                            showEditSheet = false
                        }
                    } label:
                    {
                        Text("Save Changes")
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
        .alert("Delete Goal?", isPresented: $showDeleteConfirmation)
        {
            Button("Cancel", role: .cancel)
            {
                withAnimation(.spring())
                {
                    dragOffset = 0
                    revealedAction = nil
                }
            }
            
            Button("Delete", role: .destructive)
            {
                onDelete()
            }
        } message:
        {
            Text("Are you sure you want to delete \"\(goal.title)\"?")
        }
    }
}
