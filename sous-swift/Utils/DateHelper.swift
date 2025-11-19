import Foundation

@MainActor
class DateHelper {
    static func toString(_ date: Date) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.string(from: date)
    }
    
    static func fromString(_ string: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.date(from: string)
    }

    static func isWithinThreeDaysOrPast(_ date: Date) -> Bool {
        let now = Date()
        let threeDaysBefore = Calendar.current.date(
            byAdding: .day,
            value: -3,
            to: date
        )!
        return now >= threeDaysBefore
    }
}
