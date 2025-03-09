import ArgumentParser
import Foundation

struct RemoveCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Remove a task from your list 🗑️"
    )
    
    @Argument(help: "Which task would you like to remove? (enter its number)")
    var number: Int
    
    func run() throws {
        var todos = try Todo.storage.readTodos()
        guard number > 0 && number <= todos.count else {
            throw ValidationError("Oops! That task number doesn't exist. Try 'todo list' to see your tasks and their numbers 🔍")
        }
        let todo = todos[number - 1]
        todos.remove(at: number - 1)
        try Todo.storage.writeTodos(todos)
        print("🗑️ Task removed:")
        print(todo.format(index: number))
    }
} 