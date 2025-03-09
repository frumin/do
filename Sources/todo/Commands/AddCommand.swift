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
    
    func run() throws {
        var todos = try Todo.storage.readTodos()
        
        let priority = Priority(rawValue: self.priority?.lowercased() ?? "") ?? .none
        let newTodo = TodoItem(title: item.joined(separator: " "), priority: priority)
        
        todos.append(newTodo)
        try Todo.storage.writeTodos(todos)
    }
} 