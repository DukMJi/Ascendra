import Foundation

extension DateFormatter
{
    // Used for saving dates like 5/17/26.
    static let shortDate: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    // Used for weekly chart labels like M T W T F S S.
    static let weekdayLetter: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter
    }()
}
