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
    
    @Option(name: .shortAndLong, help: """
        Due date. Supports:
        - ISO format (YYYY-MM-DD)
        - Natural language ('tomorrow', 'next monday')
        - Relative ('in 2 weeks', 'in 3 days')
        """)
    var due: String?
    
    @Option(name: .shortAndLong, help: "Tags (comma-separated)")
    var tags: String?
    
    func run() throws {
        var todos = try Todo.storage.readTodos()
        
        let priority = Priority(rawValue: self.priority?.lowercased() ?? "") ?? .none
        let dueDate = try due.map { try DateParser.parse($0) }
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