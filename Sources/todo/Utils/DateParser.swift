import Foundation

enum DateParserError: Error {
    case invalidFormat
    
    var description: String {
        switch self {
        case .invalidFormat:
            return """
                I couldn't understand that date format 📅
                You can use:
                - Calendar dates (like '2024-03-15')
                - Natural phrases (like 'tomorrow' or 'next monday')
                - Relative times (like 'in 2 minutes', 'in 3 hours', 'in 4 days')
                """
        }
    }
}

struct DateParser {
    static func parse(_ input: String) throws -> Date {
        // First try ISO format
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"
        isoFormatter.timeZone = .current
        if let date = isoFormatter.date(from: input) {
            return Calendar.current.startOfDay(for: date)
        }
        
        // Try natural language parsing
        let lowercased = input.lowercased()
        let now = Date()
        let calendar = Calendar.current
        
        // Handle relative dates
        switch lowercased {
        case "today":
            return calendar.startOfDay(for: now)
        case "tomorrow":
            return calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
        case "next week":
            return calendar.startOfDay(for: calendar.date(byAdding: .weekOfYear, value: 1, to: now)!)
        case "next month":
            return calendar.startOfDay(for: calendar.date(byAdding: .month, value: 1, to: now)!)
        default:
            break
        }
        
        // Handle "next" + weekday
        let weekdays = [
            "monday": 2, "tuesday": 3, "wednesday": 4, "thursday": 5,
            "friday": 6, "saturday": 7, "sunday": 1
        ]
        
        for (day, weekdayNum) in weekdays {
            if lowercased.contains("next \(day)") {
                let today = calendar.component(.weekday, from: now)
                var daysToAdd = weekdayNum - today
                if daysToAdd <= 0 {
                    daysToAdd += 7
                }
                return calendar.startOfDay(for: calendar.date(byAdding: .day, value: daysToAdd, to: now)!)
            }
        }
        
        // Handle "in X minutes/hours/days/weeks/months"
        if lowercased.starts(with: "in ") {
            let parts = lowercased.dropFirst(3).split(separator: " ")
            if parts.count == 2,
               let number = Int(parts[0]) {
                let unit = parts[1].lowercased()
                
                // Handle plural forms
                let singularUnit = unit.hasSuffix("s") ? String(unit.dropLast()) : unit
                
                switch singularUnit {
                case "minute", "min":
                    return calendar.date(byAdding: .minute, value: number, to: now)!
                case "hour", "hr":
                    return calendar.date(byAdding: .hour, value: number, to: now)!
                case "day":
                    return calendar.startOfDay(for: calendar.date(byAdding: .day, value: number, to: now)!)
                case "week", "wk":
                    return calendar.startOfDay(for: calendar.date(byAdding: .weekOfYear, value: number, to: now)!)
                case "month":
                    return calendar.startOfDay(for: calendar.date(byAdding: .month, value: number, to: now)!)
                default:
                    break
                }
            }
        }
        
        // Handle "X minutes/hours/days/weeks/months" (without "in")
        let parts = lowercased.split(separator: " ")
        if parts.count == 2,
           let number = Int(parts[0]) {
            let unit = parts[1].lowercased()
            
            // Handle plural forms
            let singularUnit = unit.hasSuffix("s") ? String(unit.dropLast()) : unit
            
            switch singularUnit {
            case "minute", "min":
                return calendar.date(byAdding: .minute, value: number, to: now)!
            case "hour", "hr":
                return calendar.date(byAdding: .hour, value: number, to: now)!
            case "day":
                return calendar.startOfDay(for: calendar.date(byAdding: .day, value: number, to: now)!)
            case "week", "wk":
                return calendar.startOfDay(for: calendar.date(byAdding: .weekOfYear, value: number, to: now)!)
            case "month":
                return calendar.startOfDay(for: calendar.date(byAdding: .month, value: number, to: now)!)
            default:
                break
            }
        }
        
        // If all parsing attempts fail
        throw DateParserError.invalidFormat
    }
} 