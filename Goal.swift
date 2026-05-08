import Foundation

// Goal struct, Identifiable lets SwiftUI use it inside ForEach.
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
