import ArgumentParser
import Foundation

struct EditCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "edit",
        abstract: "Update one of your tasks ✏️"
    )
    
    @Argument(help: "Which task would you like to update? (enter its number)")
    var number: Int
    
    @Option(name: .shortAndLong, help: "Change what the task says")
    var text: String?
    
    @Option(name: .shortAndLong, help: "Change how important this task is (high/medium/low)")
    var priority: String?
    
    @Option(name: .shortAndLong, help: """
        Change when it's due. You can use:
        - Calendar dates (YYYY-MM-DD)
        - Natural phrases ('tomorrow', 'next monday')
        - Relative times ('in 2 weeks', 'in 3 days')
        - 'none' to remove the due date
        """)
    var due: String?
    
    @Option(name: .shortAndLong, help: "Update task tags (comma-separated, use 'none' to remove all tags)")
    var tags: String?
    
    func run() throws {
        var todos = try Todo.storage.readTodos()
        guard number > 0 && number <= todos.count else {
            throw ValidationError("Oops! That task number doesn't exist. Try 'todo list' to see your tasks and their numbers 🔍")
        }
        
        let oldTodo = todos[number - 1]
        
        // Process new values
        let newPriority: Priority?
        if let priorityStr = priority?.lowercased() {
            if let p = Priority(rawValue: priorityStr) {
                newPriority = p
            } else {
                throw ValidationError("""
                    I don't recognize that priority level 🤔
                    You can use: 'high', 'medium', or 'low'
                    """)
            }
        } else {
            newPriority = nil
        }
        
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
            print("No changes made. Try --help to see what you can change!")
            return
        }
        
        todos[number - 1] = newTodo
        try Todo.storage.writeTodos(todos)
        print("✏️ Task updated:")
        print(newTodo.format(index: number))
    }
} 