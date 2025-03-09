import ArgumentParser
import Foundation

struct EditCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "edit",
        abstract: "Edit a todo item"
    )
    
    @Argument(help: "The number of the todo item to edit")
    var number: Int
    
    @Option(name: .shortAndLong, help: "New text for the todo")
    var text: String?
    
    @Option(name: .shortAndLong, help: "New priority level (high/medium/low)")
    var priority: String?
    
    @Option(name: .shortAndLong, help: """
        New due date. Supports:
        - ISO format (YYYY-MM-DD)
        - Natural language ('tomorrow', 'next monday')
        - Relative ('in 2 weeks', 'in 3 days')
        - 'none' to remove due date
        """)
    var due: String?
    
    @Option(name: .shortAndLong, help: "New tags (comma-separated, 'none' to remove all tags)")
    var tags: String?
    
    func run() throws {
        var todos = try Todo.storage.readTodos()
        guard number > 0 && number <= todos.count else {
            throw ValidationError("Invalid todo number")
        }
        
        let oldTodo = todos[number - 1]
        
        // Process new values
        let newPriority = priority.map { Priority(rawValue: $0.lowercased()) ?? .none }
        
        let newDueDate: Date?
        if let due = due {
            if due.lowercased() == "none" {
                newDueDate = nil
            } else {
                newDueDate = try DateParser.parse(due)
            }
        } else {
            newDueDate = nil
        }
        
        let newTags: Set<String>?
        if let tags = tags {
            if tags.lowercased() == "none" {
                newTags = []
            } else {
                newTags = Set(tags.split(separator: ",").map(String.init))
            }
        } else {
            newTags = nil
        }
        
        // Create updated todo
        let newTodo = TodoItem(
            existing: oldTodo,
            title: text,
            priority: newPriority,
            dueDate: due != nil ? newDueDate : oldTodo.dueDate,
            tags: newTags
        )
        
        if newTodo.title == oldTodo.title &&
           newTodo.priority == oldTodo.priority &&
           newTodo.dueDate == oldTodo.dueDate &&
           newTodo.tags == oldTodo.tags {
            print("No changes specified. Use --help to see available options.")
            return
        }
        
        todos[number - 1] = newTodo
        try Todo.storage.writeTodos(todos)
        print("Todo updated successfully:")
        print(newTodo.format(index: number))
    }
} 