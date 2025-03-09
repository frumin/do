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
    let id: UUID
    let title: String
    var priority: Priority
    let createdAt: Date
    var dueDate: Date?
    var tags: Set<String>
    
    init(title: String, priority: Priority = .none, dueDate: Date? = nil, tags: Set<String> = []) {
        self.id = UUID()
        self.title = title
        self.priority = priority
        self.createdAt = Date()
        self.dueDate = dueDate
        self.tags = tags
    }
    
    init(existing: TodoItem, title: String? = nil, priority: Priority? = nil, dueDate: Date? = nil, tags: Set<String>? = nil) {
        self.id = existing.id
        self.title = title ?? existing.title
        self.priority = priority ?? existing.priority
        self.createdAt = existing.createdAt
        self.dueDate = dueDate ?? existing.dueDate
        self.tags = tags ?? existing.tags
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        priority = try container.decode(Priority.self, forKey: .priority)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        tags = try container.decodeIfPresent(Set<String>.self, forKey: .tags) ?? []
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return Date() > dueDate
    }
    
    func format(index: Int, colored: Bool = true) -> String {
        let reset = "\u{001B}[0m"
        let priorityText = colored ? "\(priority.color)\(priority.symbol)\(reset)" : priority.symbol
        
        var result = "\(index). \(priorityText) \(title)"
        
        if let dueDate = dueDate {
            let dateFormatter = DateFormatter()
            
            // For dates within 24 hours, show time
            if dueDate.timeIntervalSinceNow < 24 * 3600 {
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
                let dueDateColor = colored ? (isOverdue ? "\u{001B}[31m" : "\u{001B}[36m") : ""
                result += " \(dueDateColor)⏰ \(dateFormatter.string(from: dueDate))\(colored ? reset : "")"
            } else {
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                let dueDateColor = colored ? (isOverdue ? "\u{001B}[31m" : "\u{001B}[36m") : ""
                result += " \(dueDateColor)📅 \(dateFormatter.string(from: dueDate))\(colored ? reset : "")"
            }
        }
        
        if !tags.isEmpty {
            let tagsColor = colored ? "\u{001B}[35m" : ""
            let tagsList = tags.map { "#\($0)" }.joined(separator: " ")
            result += " \(tagsColor)\(tagsList)\(colored ? reset : "")"
        }
        
        return result
    }
} 