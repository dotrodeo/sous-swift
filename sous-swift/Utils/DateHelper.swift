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

    static func relative(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named

        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)

        return formatter.localizedString(for: target, relativeTo: today)
    }

    static func upcomingFormat(_ date: Date) -> String {
        let calendar = Calendar.current

        // Check if the date is within the next 3 days (including today)
        if let threeDaysFromNow = calendar.date(
            byAdding: .day,
            value: 3,
            to: Date()
        ),
            date <= threeDaysFromNow
        {

            // Show weekday name (e.g. "Thursday")
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }

        // Otherwise show MM/DD/YYYY
        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "MM/dd/yyyy"
        return fullFormatter.string(from: date)
    }
}
