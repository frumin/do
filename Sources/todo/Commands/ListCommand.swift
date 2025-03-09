import ArgumentParser
import Foundation

struct ListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all todo items"
    )
    
    @Flag(name: .shortAndLong, help: "Sort by priority")
    var byPriority = false
    
    @Flag(name: .shortAndLong, help: "Sort by due date")
    var byDue = false
    
    @Flag(name: .shortAndLong, help: "Show only high priority items")
    var highPriority = false
    
    @Flag(name: .shortAndLong, help: "Show only overdue items")
    var overdue = false
    
    @Option(name: .shortAndLong, help: "Filter by tag")
    var tag: String?
    
    @Flag(name: .shortAndLong, help: "Disable colored output")
    var noColor = false
    
    static func listTodos(
        to output: inout some TextOutputStream,
        todos: [TodoItem],
        byPriority: Bool = false,
        byDue: Bool = false,
        highPriorityOnly: Bool = false,
        overdueOnly: Bool = false,
        tag: String? = nil,
        colored: Bool = true
    ) throws {
        var displayTodos = todos
        
        // Apply filters
        if highPriorityOnly {
            displayTodos = displayTodos.filter { $0.priority == .high }
        }
        
        if overdueOnly {
            displayTodos = displayTodos.filter { $0.isOverdue }
        }
        
        if let tag = tag {
            displayTodos = displayTodos.filter { $0.tags.contains(tag) }
        }
        
        // Apply sorting
        if byPriority {
            displayTodos.sort { $0.priority < $1.priority }
        } else if byDue {
            displayTodos.sort { lhs, rhs in
                switch (lhs.dueDate, rhs.dueDate) {
                case (nil, nil): return false
                case (nil, _): return false
                case (_, nil): return true
                case (let lhsDate?, let rhsDate?): return lhsDate < rhsDate
                }
            }
        }
        
        if displayTodos.isEmpty {
            print("No todos found!", to: &output)
            return
        }
        
        for (index, todo) in displayTodos.enumerated() {
            print(todo.format(index: index + 1, colored: colored), to: &output)
        }
    }
    
    func run() throws {
        var stdout = StandardOutputStream()
        let todos = try Todo.storage.readTodos()
        try ListCommand.listTodos(
            to: &stdout,
            todos: todos,
            byPriority: byPriority,
            byDue: byDue,
            highPriorityOnly: highPriority,
            overdueOnly: overdue,
            tag: tag,
            colored: !noColor
        )
    }
}

// Helper types for output handling
struct StandardOutputStream: TextOutputStream {
    func write(_ string: String) {
        print(string, terminator: "")
    }
}

struct StringOutputStream: TextOutputStream {
    private(set) var output: String = ""
    
    mutating func write(_ string: String) {
        output += string
    }
} 