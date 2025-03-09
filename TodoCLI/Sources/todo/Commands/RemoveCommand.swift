import Foundation
import ArgumentParser
import TodoKit

struct RemoveCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Remove todos from your list 🗑️"
    )
    
    @Argument(help: "The numbers of the todos to remove")
    var numbers: [Int]
    
    mutating func run() throws {
        let todos = try Todo.storage.readTodos()
        
        // Validate numbers
        guard !numbers.isEmpty else {
            throw ValidationError("Please specify which todos to remove.")
        }
        
        let sortedNumbers = numbers.sorted()
        guard let maxNumber = sortedNumbers.last, maxNumber <= todos.count else {
            throw ValidationError("Invalid todo number. Please use numbers between 1 and \(todos.count).")
        }
        
        guard let minNumber = sortedNumbers.first, minNumber > 0 else {
            throw ValidationError("Todo numbers must be greater than 0.")
        }
        
        // Remove todos
        if sortedNumbers.count == 1 {
            let todo = todos[sortedNumbers[0] - 1]
            try Todo.storage.archiveTodo(todo, reason: .deleted)
            print("🗑️ Task removed:")
            print(todo.format(index: sortedNumbers[0]))
        } else {
            print("🗑️ Tasks removed:")
            for number in sortedNumbers {
                let todo = todos[number - 1]
                try Todo.storage.archiveTodo(todo, reason: .deleted)
                print(todo.format(index: number))
            }
        }
    }
} 