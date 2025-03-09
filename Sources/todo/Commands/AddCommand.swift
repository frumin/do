import ArgumentParser
import Foundation

struct AddCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add a new todo item"
    )
    
    @Argument(help: "The todo item to add")
    var item: [String]
    
    @Option(name: .shortAndLong, help: "Priority level (high/medium/low)")
    var priority: String?
    
    @Option(name: .shortAndLong, help: "Due date (format: YYYY-MM-DD)")
    var due: String?
    
    @Option(name: .shortAndLong, help: "Tags (comma-separated)")
    var tags: String?
    
    private func parseDate(_ dateString: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            return date
        }
        throw ValidationError("Invalid date format. Please use YYYY-MM-DD")
    }
    
    func run() throws {
        var todos = try Todo.storage.readTodos()
        
        let priority = Priority(rawValue: self.priority?.lowercased() ?? "") ?? .none
        let dueDate = try due.map { try parseDate($0) }
        let tags = Set(tags?.split(separator: ",").map(String.init) ?? [])
        
        let newTodo = TodoItem(
            title: item.joined(separator: " "),
            priority: priority,
            dueDate: dueDate,
            tags: tags
        )
        
        todos.append(newTodo)
        try Todo.storage.writeTodos(todos)
    }
} 