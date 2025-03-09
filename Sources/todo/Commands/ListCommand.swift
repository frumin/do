import ArgumentParser
import Foundation

struct ListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all todo items"
    )
    
    @Flag(name: .shortAndLong, help: "Sort by priority")
    var byPriority = false
    
    @Flag(name: .shortAndLong, help: "Show only high priority items")
    var highPriority = false
    
    @Flag(name: .shortAndLong, help: "Disable colored output")
    var noColor = false
    
    static func listTodos(to output: inout some TextOutputStream, todos: [TodoItem], byPriority: Bool = false, highPriorityOnly: Bool = false, colored: Bool = true) throws {
        var displayTodos = todos
        
        if highPriorityOnly {
            displayTodos = todos.filter { $0.priority == .high }
        }
        
        if byPriority {
            displayTodos.sort { $0.priority < $1.priority }
        }
        
        if displayTodos.isEmpty {
            print("No todos yet!", to: &output)
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
            highPriorityOnly: highPriority,
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