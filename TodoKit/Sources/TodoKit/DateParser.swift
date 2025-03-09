import Foundation

public enum DateParser {
    public static func parse(_ input: String) throws -> Date? {
        // Try exact date format first
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: input) {
            return date
        }
        
        // Try natural language parsing
        let lowercased = input.lowercased()
        let now = Date()
        let calendar = Calendar.current
        
        // Handle relative dates
        if lowercased == "today" {
            return now
        } else if lowercased == "tomorrow" {
            return calendar.date(byAdding: .day, value: 1, to: now)
        } else if lowercased == "next week" {
            return calendar.date(byAdding: .weekOfYear, value: 1, to: now)
        }
        
        // Handle "in X days/weeks/months"
        let pattern = #"in (\d+) (day|days|week|weeks|month|months)"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: lowercased, range: NSRange(lowercased.startIndex..., in: lowercased)) {
            let numberRange = Range(match.range(at: 1), in: lowercased)!
            let unitRange = Range(match.range(at: 2), in: lowercased)!
            
            let number = Int(lowercased[numberRange])!
            let unit = lowercased[unitRange]
            
            var calendarComponent: Calendar.Component
            switch unit {
            case "day", "days": calendarComponent = .day
            case "week", "weeks": calendarComponent = .weekOfYear
            case "month", "months": calendarComponent = .month
            default: return nil
            }
            
            return calendar.date(byAdding: calendarComponent, value: number, to: now)
        }
        
        // Handle "next monday", etc.
        let weekdays = ["monday": 2, "tuesday": 3, "wednesday": 4, "thursday": 5,
                       "friday": 6, "saturday": 7, "sunday": 1]
        for (name, weekday) in weekdays {
            if lowercased.contains("next \(name)") {
                var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
                components.weekday = weekday
                components.weekOfYear! += 1
                return calendar.date(from: components)
            }
        }
        
        return nil
    }
} 