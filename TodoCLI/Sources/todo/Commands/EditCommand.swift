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
    var priority: String?
    
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
            throw ValidationError("Todo #\(number) not found. Available todo numbers: 1 to \(todos.count)")
        }
        
        var todo = todos[number - 1]
        let oldTodo = todo
        var changes: [String] = []
        
        if let newTitle = title {
            todo.title = newTitle
            changes.append("title")
        }
        
        if let priorityString = priority {
            todo.priority = Priority(rawValue: priorityString.lowercased()) ?? .none
            changes.append("priority")
        }
        
        if let dueDateString = due {
            guard let parsedDate = try DateParser.parse(dueDateString) else {
                throw ValidationError("Invalid date format. Try using:\n• A specific date: YYYY-MM-DD\n• Natural language: \"tomorrow\", \"next monday 2pm\", \"in 2 days\"")
            }
            todo.dueDate = parsedDate
            changes.append("due date")
        }
        
        if let tagString = tags {
            todo.tags = tagString.split(separator: ",").map(String.init)
            changes.append("tags")
        }
        
        if changes.isEmpty {
            print("\nℹ️  No changes made to todo #\(number)")
            return
        }
        
        todos[number - 1] = todo
        try Todo.storage.writeTodos(todos)
        
        print("\n✏️  Updated todo #\(number):")
        print("────────────────────")
        print("Before: \(oldTodo.format(index: number))")
        print("After:  \(todo.format(index: number))")
        print("\nChanged: \(changes.joined(separator: ", "))")
        
        print("\n💡 Quick actions:")
        print("• View all todos: todo list")
        if todo.priority == .none {
            print("• Set priority: todo edit \(number) -p high")
        }
        if todo.dueDate == nil {
            print("• Add due date: todo edit \(number) -d \"tomorrow 2pm\"")
        }
        if todo.tags.isEmpty {
            print("• Add tags: todo edit \(number) -t \"work,important\"")
        }
    }
} 