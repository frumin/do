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
    
    @Option(name: [.customShort("p"), .long], help: "New priority (high, medium, low)")
    var priority: Todo.Priority?
    
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
            throw ValidationError("Invalid todo number. Please use a number between 1 and \(todos.count).")
        }
        
        let oldTodo = todos[number - 1]
        
        let dueDate = try due.flatMap { input in
            try DateParser.parse(input)
        }
        
        let tagList = tags?.split(separator: ",").map(String.init)
        
        let newTodo = Todo(
            id: oldTodo.id,
            title: title ?? oldTodo.title,
            priority: priority ?? oldTodo.priority,
            dueDate: removeDue ? nil : (dueDate ?? oldTodo.dueDate),
            tags: removeTags ? [] : (tagList ?? oldTodo.tags),
            createdAt: oldTodo.createdAt
        )
        
        todos[number - 1] = newTodo
        try Todo.storage.writeTodos(todos)
        
        print("✏️ Updated todo:")
        print("Before: \(oldTodo.format(index: number))")
        print("After:  \(newTodo.format(index: number))")
    }
} 