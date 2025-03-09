import Foundation

enum ArchiveReason: String, Codable {
    case completed
    case deleted
    case expired
}

struct ArchivedTodoItem: Codable {
    let todo: TodoItem
    let archivedAt: Date
    let reason: ArchiveReason
    
    func format(index: Int, colored: Bool = true) -> String {
        let reset = "\u{001B}[0m"
        let gray = colored ? "\u{001B}[90m" : ""
        
        var result = "\(index). \(gray)[\(reason.rawValue.uppercased())] \(todo.format(index: index, colored: colored))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        result += " (archived \(dateFormatter.string(from: archivedAt)))\(colored ? reset : "")"
        
        return result
    }
} 