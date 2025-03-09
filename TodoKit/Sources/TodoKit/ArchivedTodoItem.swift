import Foundation

public enum ArchiveReason: String, Codable {
    case completed
    case deleted
    case expired
}

public struct ArchivedTodoItem: Codable {
    public let todo: Todo
    public let archivedAt: Date
    public let reason: ArchiveReason
    
    public init(todo: Todo, archivedAt: Date, reason: ArchiveReason) {
        self.todo = todo
        self.archivedAt = archivedAt
        self.reason = reason
    }
    
    public func format(index: Int, colored: Bool = true) -> String {
        let reset = "\u{001B}[0m"
        let gray = colored ? "\u{001B}[90m" : ""
        
        var result = "\(index). \(gray)[\(reason.rawValue.uppercased())] \(todo.format(index: index))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        result += " (archived \(dateFormatter.string(from: archivedAt)))\(colored ? reset : "")"
        
        return result
    }
} 