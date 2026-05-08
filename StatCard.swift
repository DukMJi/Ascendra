import SwiftUI

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
