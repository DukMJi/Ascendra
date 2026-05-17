import Foundation

// Stores one completed goal check-in.
// Later this can power weekly stats, charts, and Circle momentum.
struct CheckInRecord: Identifiable, Codable
{
    var id = UUID()
    var goalTitle: String
    var goalIcon: String
    var dateString: String
}
