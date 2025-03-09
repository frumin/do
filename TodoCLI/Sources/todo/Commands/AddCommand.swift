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
            do {
                todo.dueDate = try DateParser.parse(dueString)
            } catch {
                throw ValidationError("Invalid date format. Please use YYYY-MM-DD or natural language like 'tomorrow'.")
            }
        }
        
        if let tagsString = tags {
            todo.tags = tagsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        
        try Todo.storage.addTodo(todo)
        let todos = try Todo.storage.readTodos()
        print("\n✨ Added new todo:")
        print("─────────────────")
        print(todo.format(index: todos.count))
        
        // Show helpful next steps
        print("\n📝 Next steps:")
        print("• List all todos: todo list")
        if todo.priority == .none {
            print("• Set priority: todo edit \(todos.count) --priority 1")
        }
        if todo.dueDate == nil {
            print("• Add due date: todo edit \(todos.count) --due \"tomorrow 2pm\"")
        }
        if todo.tags.isEmpty {
            print("• Add tags: todo edit \(todos.count) --tags \"work,important\"")
        }
    }
} 