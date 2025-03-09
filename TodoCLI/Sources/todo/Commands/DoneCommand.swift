import Foundation
import ArgumentParser
import TodoKit

struct DoneCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "done",
        abstract: "Mark todos as done ✅"
    )
    
    @Argument(help: "The numbers of the todos to mark as done")
    var numbers: [Int]
    
    mutating func run() throws {
        let todos = try Todo.storage.readTodos()
        
        // Validate numbers
        guard !numbers.isEmpty else {
            throw ValidationError("Please specify which todos to mark as done.")
        }
        
        let sortedNumbers = numbers.sorted()
        guard let maxNumber = sortedNumbers.last, maxNumber <= todos.count else {
            throw ValidationError("Invalid todo number. Please use numbers between 1 and \(todos.count).")
        }
        
        guard let minNumber = sortedNumbers.first, minNumber > 0 else {
            throw ValidationError("Todo numbers must be greater than 0.")
        }
        
        // Mark todos as done
        if sortedNumbers.count == 1 {
            let todo = todos[sortedNumbers[0] - 1]
            try Todo.storage.archiveTodo(todo, reason: .completed)
            print("✅ Marked as done:")
            print(todo.format(index: sortedNumbers[0]))
        } else {
            print("✅ Marked as done:")
            for number in sortedNumbers {
                let todo = todos[number - 1]
                try Todo.storage.archiveTodo(todo, reason: .completed)
                print(todo.format(index: number))
            }
        }
    }
} 