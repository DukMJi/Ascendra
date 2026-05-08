import SwiftUI

struct ProfileScreen: View
{
    @AppStorage("xp") private var xp = 120
    @AppStorage("streak") private var streak = 5
    
    var currentLevel: Int
    {
        return (xp / 100) + 1
    }
    
    var body: some View
    {
        ZStack
        {
            Color.ascendraBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24)
            {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 12)
                {
                    Circle()
                        .fill(Color.ascendraOrange.opacity(0.20))
                        .frame(width: 90, height: 90)
                        .overlay(
                            Text("T")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.ascendraOrange)
                        )
                    
                    Text("Tommy")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Level \(currentLevel)")
                        .foregroundColor(.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.ascendraCard)
                .cornerRadius(20)
                
                VStack(spacing: 12)
                {
                    ProfileStatRow(title: "Total XP", value: "\(xp)", icon: "bolt.fill")
                    ProfileStatRow(title: "Current Streak", value: "\(streak)", icon: "flame.fill")
                    ProfileStatRow(title: "Current Theme", value: "Core", icon: "paintpalette.fill")
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct ProfileStatRow: View
{
    var title: String
    var value: String
    var icon: String
    
    var body: some View
    {
        HStack(spacing: 14)
        {
            Image(systemName: icon)
                .foregroundColor(.ascendraOrange)
                .frame(width: 28)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondaryText)
        }
        .padding()
        .background(Color.ascendraCard)
        .cornerRadius(16)
    }
}
