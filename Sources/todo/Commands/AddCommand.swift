import ArgumentParser
import Foundation

struct AddCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add a new todo item"
    )
    
    @Argument(help: "The todo item to add")
    var item: [String]
    
    func run() throws {
        var todos = try TodoStorage.readTodos()
        todos.append(item.joined(separator: " "))
        try TodoStorage.writeTodos(todos)
    }
} 