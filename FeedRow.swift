import SwiftUI

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
            
            // Feed message and optional note.
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
