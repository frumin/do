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
        
        if let dueDateString = due {
            guard let parsedDate = try DateParser.parse(dueDateString) else {
                throw ValidationError("Invalid date format. Try using:\n• A specific date: YYYY-MM-DD\n• Natural language: \"tomorrow\", \"next monday 2pm\", \"in 2 days\"")
            }
            todo.dueDate = parsedDate
        }
        
        if let tagsString = tags {
            todo.tags = tagsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        
        try Todo.storage.addTodo(todo)
        let todos = try Todo.storage.readTodos()
        print("\n✨ Added todo #\(todos.count):")
        print("───────────────────")
        print(todo.format(index: todos.count))
        
        print("\n💡 Quick actions:")
        print("• View all todos: todo list")
        if priority == nil {
            print("• Set priority: todo edit \(todos.count) -p high")
        }
        if due == nil {
            print("• Add due date: todo edit \(todos.count) -d \"tomorrow 2pm\"")
        }
        if tags?.isEmpty != false {
            print("• Add tags: todo edit \(todos.count) -t \"work,important\"")
        }
    }
} 