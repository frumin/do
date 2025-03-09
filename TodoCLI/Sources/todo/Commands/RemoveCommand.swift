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
        var todos = try Todo.storage.readTodos()
        var archive = try Todo.storage.readArchive()
        
        // Validate all numbers before making any changes
        let sortedNumbers = numbers.sorted(by: >)  // Sort in descending order to remove from end first
        for number in sortedNumbers {
            guard number > 0 && number <= todos.count else {
                throw ValidationError("Todo #\(number) doesn't exist. Valid numbers are 1 to \(todos.count).")
            }
        }
        
        print("\n🗑️ Removing todos:")
        print("───────────────")
        
        var removedTodos: [Todo] = []
        
        // Remove todos in descending order
        for number in sortedNumbers {
            let todo = todos[number - 1]
            print(todo.format(index: number))
            
            // Archive the todo
            let archivedItem = ArchivedTodoItem(todo: todo, archivedAt: Date(), reason: .deleted)
            archive.append(archivedItem)
            
            // Remove from active todos
            todos.remove(at: number - 1)
            removedTodos.append(todo)
        }
        
        try Todo.storage.writeTodos(todos)
        try Todo.storage.writeArchive(archive)
        
        if removedTodos.count > 1 {
            print("\n🗑️  Removed \(removedTodos.count) todos:")
            print("────────────────────────")
            for (index, todo) in removedTodos.enumerated() {
                print(todo.format(index: index + 1))
            }
        } else if let todo = removedTodos.first {
            print("\n🗑️  Removed todo:")
            print("───────────────")
            print(todo.format(index: numbers[0]))
        }
        
        let remainingTodos = try Todo.storage.readTodos()
        if remainingTodos.isEmpty {
            print("\n📝 No todos left. What's next?")
            print("• Add new todo: todo add \"task name\"")
            print("• View removed: todo archive")
            print("• See statistics: todo stats")
        } else {
            print("\n💡 Quick actions:")
            print("• View remaining todos: todo list")
            print("• View removed todos: todo archive")
            print("• See statistics: todo stats")
        }
    }
} 