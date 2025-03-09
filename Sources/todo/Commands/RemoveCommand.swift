import ArgumentParser
import Foundation

struct RemoveCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Remove a todo item"
    )
    
    @Argument(help: "The number of the todo item to remove")
    var number: Int
    
    func run() throws {
        var todos = try Todo.storage.readTodos()
        guard number > 0 && number <= todos.count else {
            throw ValidationError("Invalid todo number")
        }
        todos.remove(at: number - 1)
        try Todo.storage.writeTodos(todos)
    }
} 