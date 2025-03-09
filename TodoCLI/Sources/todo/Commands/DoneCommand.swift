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
        var todos = try Todo.storage.readTodos()
        var archive = try Todo.storage.readArchive()
        
        // Validate all numbers before making any changes
        let sortedNumbers = numbers.sorted(by: >)  // Sort in descending order to remove from end first
        for number in sortedNumbers {
            guard number > 0 && number <= todos.count else {
                throw ValidationError("Todo #\(number) doesn't exist. Valid numbers are 1 to \(todos.count).")
            }
        }
        
        print("\n✅ Marking as done:")
        print("────────────────")
        
        var completedTodos: [Todo] = []
        
        // Remove todos in descending order
        for number in sortedNumbers {
            let todo = todos[number - 1]
            print(todo.format(index: number))
            
            // Archive the todo
            let archivedItem = ArchivedTodoItem(todo: todo, archivedAt: Date(), reason: .completed)
            archive.append(archivedItem)
            
            // Remove from active todos
            todos.remove(at: number - 1)
            
            completedTodos.append(todo)
        }
        
        try Todo.storage.writeTodos(todos)
        try Todo.storage.writeArchive(archive)
        
        if completedTodos.count > 1 {
            print("\n✅ Completed \(completedTodos.count) todos:")
            print("─────────────────────────")
            for (index, todo) in completedTodos.enumerated() {
                print(todo.format(index: index + 1))
            }
        } else if let todo = completedTodos.first {
            print("\n✅ Completed todo:")
            print("────────────────")
            print(todo.format(index: numbers[0]))
        }
        
        let remainingTodos = try Todo.storage.readTodos()
        if remainingTodos.isEmpty {
            print("\n🎯 All done! What's next?")
            print("• Add new todo: todo add \"task name\"")
            print("• View completed: todo archive")
            print("• See statistics: todo stats")
        } else {
            print("\n💡 Quick actions:")
            print("• View remaining todos: todo list")
            print("• View completed todos: todo archive")
            print("• See statistics: todo stats")
        }
    }
} 