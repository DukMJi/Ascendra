import SwiftUI

// Sheet that allows the user to edit profile information.
struct EditProfileSheet: View
{
    // Bindings allow this sheet to directly modify values
    // stored in ProfileScreen.
    @Binding var displayName: String
    @Binding var profileInitial: String
    
    // Allows the sheet to close itself.
    @Environment(\.dismiss) var dismiss
    
    // Currently selected app theme.
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.core.rawValue
    
    // Converts saved theme string into AppTheme enum.
    var currentTheme: AppTheme
    {
        return AppTheme(rawValue: selectedTheme) ?? .core
    }
    
    // Theme colors.
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
            // Main background color.
            themeBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20)
            {
                // Sheet title.
                Text("Edit Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // User display name input.
                TextField("Display name", text: $displayName)
                    .padding()
                    .background(themeCard)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                
                // User profile initial input.
                TextField("Initial", text: $profileInitial)
                    .padding()
                    .background(themeCard)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                
                // Saves updated profile information.
                Button
                {
                    // Removes accidental spaces/newlines.
                    let trimmedName = displayName
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let trimmedInitial = profileInitial
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Prevents empty display names.
                    if !trimmedName.isEmpty
                    {
                        displayName = trimmedName
                    }
                    
                    // Prevents empty initials.
                    // Also limits initial to one uppercase character.
                    if !trimmedInitial.isEmpty
                    {
                        profileInitial = String(trimmedInitial.prefix(1))
                            .uppercased()
                    }
                    
                    // Closes the sheet.
                    dismiss()
                } label:
                {
                    Text("Save Profile")
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
