import ArgumentParser
import Foundation

struct ListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all todo items"
    )
    
    func run() throws {
        let todos = try TodoStorage.readTodos()
        for (index, todo) in todos.enumerated() {
            print("\(index + 1). \(todo)")
        }
        if todos.isEmpty {
            print("No todos yet!")
        }
    }
} 