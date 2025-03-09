import ArgumentParser
import Foundation

struct DoneCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "done",
        abstract: "Mark a todo item as done"
    )
    
    @Argument(help: "The number of the todo item to mark as done")
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