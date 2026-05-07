import SwiftUI

// Shared date formatter used for checking whether a new day has started.
extension DateFormatter
{
    static let shortDate: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
