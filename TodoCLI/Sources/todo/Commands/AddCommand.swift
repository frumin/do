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
        print("\n✨ Added new todo:")
        print("─────────────────")
        print(todo.format())
        
        // Show helpful next steps
        print("\n📝 Next steps:")
        print("• List all todos: todo list")
        if todo.priority == .none {
            print("• Set priority: todo edit \(try Todo.storage.readTodos().count) --priority 1")
        }
        if todo.dueDate == nil {
            print("• Add due date: todo edit \(try Todo.storage.readTodos().count) --due \"tomorrow 2pm\"")
        }
        if todo.tags.isEmpty {
            print("• Add tags: todo edit \(try Todo.storage.readTodos().count) --tags \"work,important\"")
        }
    }
} 