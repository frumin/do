import Foundation
import SwiftDate

enum DateParserError: Error {
    case invalidFormat
    
    var description: String {
        switch self {
        case .invalidFormat:
            return "Invalid date format. Try formats like: 'tomorrow', 'next monday', 'in 2 weeks', or YYYY-MM-DD"
        }
    }
}

struct DateParser {
    static func parse(_ input: String) throws -> Date {
        // First try ISO format
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"
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
            return now
        case "tomorrow":
            return now + 1.days
        case "next week":
            return now + 7.days
        case "next month":
            return now + 1.months
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
        
        // Handle "in X days/weeks/months"
        if lowercased.starts(with: "in ") {
            let parts = lowercased.dropFirst(3).split(separator: " ")
            if parts.count == 2,
               let number = Int(parts[0]),
               let unit = parts[1].first {
                switch unit {
                case "d": // days
                    return now + number.days
                case "w": // weeks
                    return now + (number * 7).days
                case "m": // months
                    return now + number.months
                default:
                    break
                }
            }
        }
        
        // If all parsing attempts fail
        throw DateParserError.invalidFormat
    }
} 