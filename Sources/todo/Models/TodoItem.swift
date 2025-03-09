import Foundation

enum Priority: String, Codable, Comparable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    case none = "none"
    
    var symbol: String {
        switch self {
        case .high: return "⚡"
        case .medium: return "●"
        case .low: return "○"
        case .none: return " "
        }
    }
    
    var color: String {
        switch self {
        case .high: return "\u{001B}[31m" // Red
        case .medium: return "\u{001B}[33m" // Yellow
        case .low: return "\u{001B}[32m" // Green
        case .none: return "\u{001B}[0m" // Default
        }
    }
    
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        let order: [Priority] = [.high, .medium, .low, .none]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

struct TodoItem: Codable {
    let title: String
    var priority: Priority
    let createdAt: Date
    
    init(title: String, priority: Priority = .none) {
        self.title = title
        self.priority = priority
        self.createdAt = Date()
    }
    
    func format(index: Int, colored: Bool = true) -> String {
        let reset = "\u{001B}[0m"
        let priorityText = colored ? "\(priority.color)\(priority.symbol)\(reset)" : priority.symbol
        return "\(index). \(priorityText) \(title)"
    }
} 