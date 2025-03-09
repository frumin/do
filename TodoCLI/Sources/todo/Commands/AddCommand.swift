import Foundation
import ArgumentParser
import TodoKit

struct AddCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add a new todo ✨"
    )
    
    @Argument(help: "The todo title")
    var title: String
    
    @Option(name: .shortAndLong, help: "Set priority (high, medium, low)")
    var priority: Todo.Priority = .none
    
    @Option(name: .shortAndLong, help: "Set due date (YYYY-MM-DD or natural language)")
    var due: String?
    
    @Option(name: .shortAndLong, help: "Add tags (comma-separated)")
    var tags: String?
    
    mutating func run() throws {
        let dueDate = try due.flatMap { input in
            try DateParser.parse(input)
        }
        
        let tagList = tags?.split(separator: ",").map(String.init) ?? []
        
        let todo = Todo(
            title: title,
            priority: priority,
            dueDate: dueDate,
            tags: tagList
        )
        
        var todos = try Todo.storage.readTodos()
        todos.append(todo)
        try Todo.storage.writeTodos(todos)
        
        print("✨ Added todo:")
        print(todo.format(index: nil))
    }
} 