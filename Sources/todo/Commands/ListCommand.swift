import ArgumentParser
import Foundation

struct ListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all todo items"
    )
    
    // Instead of storing the output stream, we'll create a static function for testing
    static func listTodos(to output: inout some TextOutputStream) throws {
        let todos = try Todo.storage.readTodos()
        for (index, todo) in todos.enumerated() {
            print("\(index + 1). \(todo)", to: &output)
        }
        if todos.isEmpty {
            print("No todos yet!", to: &output)
        }
    }
    
    func run() throws {
        var stdout = StandardOutputStream()
        try ListCommand.listTodos(to: &stdout)
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