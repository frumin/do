import Foundation
import ArgumentParser
import TodoKit

struct EditCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "edit",
        abstract: "Edit a todo ✏️"
    )
    
    @Argument(help: "The number of the todo to edit")
    var number: Int
    
    @Option(name: [.customShort("i"), .long], help: "New title")
    var title: String?
    
    @Option(name: [.customShort("p"), .long], help: "New priority (1=high, 2=medium, 3=low, 4=none)")
    var priority: Priority?
    
    @Option(name: [.customShort("d"), .long], help: "New due date (YYYY-MM-DD or natural language)")
    var due: String?
    
    @Option(name: [.customShort("t"), .long], help: "New tags (comma-separated)")
    var tags: String?
    
    @Flag(name: [.customShort("x"), .long], help: "Remove due date")
    var removeDue = false
    
    @Flag(name: [.customShort("z"), .long], help: "Remove tags")
    var removeTags = false
    
    mutating func run() throws {
        var todos = try Todo.storage.readTodos()
        guard number > 0 && number <= todos.count else {
            throw ValidationError("Invalid todo number: \(number)")
        }
        
        var todo = todos[number - 1]
        
        if let title = title {
            todo.title = title
        }
        
        if let priority = priority {
            todo.priority = priority
        }
        
        if removeDue {
            todo.dueDate = nil
        } else if let dueString = due {
            todo.dueDate = DateParser.parse(dueString)
        }
        
        if removeTags {
            todo.tags = []
        } else if let tagsString = tags {
            todo.tags = tagsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        
        todos[number - 1] = todo
        try Todo.storage.writeTodos(todos)
        
        print("✏️ Updated todo:")
        print(todo.format())
    }
} 