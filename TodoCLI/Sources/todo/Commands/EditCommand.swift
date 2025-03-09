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
            throw ValidationError("Todo #\(number) doesn't exist. Valid numbers are 1 to \(todos.count).")
        }
        
        let oldTodo = todos[number - 1]
        var todo = oldTodo
        
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
        
        print("\n✏️ Updated todo #\(number):")
        print("─────────────────────")
        if oldTodo != todo {
            print("Before: \(oldTodo.format())")
            print("After:  \(todo.format())")
            
            // Show what changed
            var changes: [String] = []
            if oldTodo.title != todo.title {
                changes.append("title")
            }
            if oldTodo.priority != todo.priority {
                changes.append("priority")
            }
            if oldTodo.dueDate != todo.dueDate {
                changes.append("due date")
            }
            if oldTodo.tags != todo.tags {
                changes.append("tags")
            }
            print("\nChanged: \(changes.joined(separator: ", "))")
            
            // Show helpful next steps
            print("\n📝 Next steps:")
            print("• List all todos: todo list")
            if todo.priority == .none {
                print("• Set priority: todo edit \(number) --priority 1")
            }
            if todo.dueDate == nil {
                print("• Add due date: todo edit \(number) --due \"tomorrow 2pm\"")
            }
            if todo.tags.isEmpty {
                print("• Add tags: todo edit \(number) --tags \"work,important\"")
            }
        } else {
            print("No changes were made to the todo.")
        }
    }
} 