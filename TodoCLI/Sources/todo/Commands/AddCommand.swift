import Foundation
import ArgumentParser
import TodoKit

struct AddCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add a new todo ✨"
    )
    
    @Argument(help: "The todo text")
    var title: String
    
    @Option(name: [.customShort("p"), .long], help: "Set priority (1=high, 2=medium, 3=low, 4=none)")
    var priority: Priority?
    
    @Option(name: [.customShort("d"), .long], help: "Set due date (YYYY-MM-DD or natural language)")
    var due: String?
    
    @Option(name: [.customShort("t"), .long], help: "Add tags (comma-separated)")
    var tags: String?
    
    mutating func run() throws {
        var todo = Todo(title: title)
        
        if let priority = priority {
            todo.priority = priority
        }
        
        if let dueString = due {
            todo.dueDate = DateParser.parse(dueString)
        }
        
        if let tagsString = tags {
            todo.tags = tagsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        
        try Todo.storage.addTodo(todo)
        print("✨ Added todo:")
        print(todo.format())
    }
} 