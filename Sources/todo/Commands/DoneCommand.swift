import ArgumentParser
import Foundation

struct DoneCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "done",
        abstract: "Celebrate completing a task! 🎉"
    )
    
    @Argument(help: "Which task did you complete? (enter its number)")
    var number: Int
    
    func run() throws {
        var todos = try Todo.storage.readTodos()
        guard number > 0 && number <= todos.count else {
            throw ValidationError("Oops! That task number doesn't exist. Try 'todo list' to see your tasks and their numbers 🔍")
        }
        let todo = todos[number - 1]
        try Todo.storage.archiveTodo(todo, reason: .completed)
        print("🎉 Great job! Task completed:")
        print(todo.format(index: number))
    }
} 