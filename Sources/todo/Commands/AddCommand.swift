import ArgumentParser
import Foundation

struct AddCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add a new task to your list ✨"
    )
    
    @Argument(help: "What would you like to add to your list?")
    var item: [String]
    
    @Option(name: .shortAndLong, help: "How important is this task? (high/medium/low)")
    var priority: String?
    
    @Option(name: .shortAndLong, help: """
        When should this be done? You can use:
        - Calendar dates (YYYY-MM-DD)
        - Natural phrases ('tomorrow', 'next monday')
        - Relative times ('in 2 weeks', 'in 3 days')
        """)
    var due: String?
    
    @Option(name: .shortAndLong, help: "Add some tags to organize your task (comma-separated)")
    var tags: String?
    
    func run() throws {
        var todos = try Todo.storage.readTodos()
        
        let priority: Priority
        if let priorityStr = self.priority?.lowercased() {
            if let p = Priority(rawValue: priorityStr) {
                priority = p
            } else {
                throw ValidationError("""
                    I don't recognize that priority level 🤔
                    You can use: 'high', 'medium', or 'low'
                    """)
            }
        } else {
            priority = .none
        }
        
        let dueDate = try due.map { try DateParser.parse($0) }
        let tags = Set(tags?.split(separator: ",").map(String.init) ?? [])
        
        let newTodo = TodoItem(
            title: item.joined(separator: " "),
            priority: priority,
            dueDate: dueDate,
            tags: tags
        )
        
        todos.append(newTodo)
        try Todo.storage.writeTodos(todos)
        print("✨ Added to your list:")
        print(newTodo.format(index: todos.count))
    }
} 