import ArgumentParser
import Foundation

struct RemoveCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Remove tasks from your list 🗑️"
    )
    
    @Argument(parsing: .remaining, help: "Which tasks would you like to remove? (enter their numbers, space-separated)")
    private var numberStrings: [String]
    
    var numbers: [Int] {
        numberStrings.compactMap { Int($0) }
    }
    
    func run() throws {
        guard !numbers.isEmpty else {
            throw ValidationError("Please specify which tasks to remove (enter their numbers)")
        }
        
        // Check if any numbers couldn't be parsed
        if numbers.count != numberStrings.count {
            throw ValidationError("Please enter valid task numbers")
        }
        
        let todos = try Todo.storage.readTodos()
        
        // Validate all numbers first
        for number in numbers {
            guard number > 0 && number <= todos.count else {
                throw ValidationError("Oops! Task #\(number) doesn't exist. Try 'todo list' to see your tasks and their numbers 🔍")
            }
        }
        
        // Sort in reverse order to handle indices correctly
        let sortedNumbers = numbers.sorted(by: >)
        
        // Remove each task
        if sortedNumbers.count == 1 {
            let todo = todos[sortedNumbers[0] - 1]
            try Todo.storage.archiveTodo(todo, reason: .deleted)
            print("🗑️ Task removed:")
            print(todo.format(index: sortedNumbers[0]))
        } else {
            print("🗑️ Removed \(sortedNumbers.count) tasks:")
            for number in sortedNumbers {
                let todo = todos[number - 1]
                try Todo.storage.archiveTodo(todo, reason: .deleted)
                print(todo.format(index: number))
            }
        }
    }
} 