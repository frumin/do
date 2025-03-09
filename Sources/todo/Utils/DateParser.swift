import Foundation
import SwiftDate

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
            return date
        }
        
        // Initialize SwiftDate
        SwiftDate.defaultRegion = Region.current
        
        // Try natural language parsing
        let lowercased = input.lowercased()
        let now = Date()
        
        // Handle relative dates
        switch lowercased {
        case "today":
            return Calendar.current.startOfDay(for: now)
        case "tomorrow":
            return Calendar.current.startOfDay(for: now + 1.days)
        case "next week":
            return Calendar.current.startOfDay(for: now + 7.days)
        case "next month":
            return Calendar.current.startOfDay(for: now + 1.months)
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
                let today = now.weekday
                var daysToAdd = weekdayNum - today
                if daysToAdd <= 0 {
                    daysToAdd += 7
                }
                return now + daysToAdd.days
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
                    return now + number.minutes
                case "hour", "hr":
                    return now + number.hours
                case "day":
                    return now + number.days
                case "week", "wk":
                    return now + (number * 7).days
                case "month":
                    return now + number.months
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
                return now + number.minutes
            case "hour", "hr":
                return now + number.hours
            case "day":
                return now + number.days
            case "week", "wk":
                return now + (number * 7).days
            case "month":
                return now + number.months
            default:
                break
            }
        }
        
        // If all parsing attempts fail
        throw DateParserError.invalidFormat
    }
} 