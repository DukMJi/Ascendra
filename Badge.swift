import Foundation

// Represents one badge in the app.
struct Badge: Identifiable, Codable
{
    let id: UUID
    var title: String
    var description: String
    var icon: String
    
    init(id: UUID = UUID(), title: String, description: String, icon: String)

    {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
    }
}
