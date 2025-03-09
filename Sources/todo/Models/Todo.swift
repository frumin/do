import Foundation
import TodoKit

typealias Todo = TodoKit.Todo
typealias Priority = Todo.Priority
typealias ArchivedTodoItem = TodoKit.ArchivedTodoItem
typealias ArchiveReason = TodoKit.ArchiveReason

extension Todo {
    static let storage = TodoKit.TodoStorage.shared
    
    static func format(_ todos: [Todo], showNumbers: Bool = true) -> String {
        guard !todos.isEmpty else { return "No todos found" }
        
        return todos.enumerated().map { index, todo in
            todo.format(index: showNumbers ? index + 1 : nil)
        }.joined(separator: "\n")
    }
    
    func format(index: Int?) -> String {
        var parts: [String] = []
        
        if let index = index {
            parts.append("\(index).")
        }
        
        parts.append(priority.symbol)
        parts.append(title)
        
        if let dueDate = formattedDueDate {
            parts.append("📅 \(dueDate)")
        }
        
        if !tags.isEmpty {
            parts.append(formattedTags)
        }
        
        return parts.joined(separator: " ")
    }
} 