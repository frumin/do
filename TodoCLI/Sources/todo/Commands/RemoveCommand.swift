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
        
        // Remove todos in descending order
        for number in sortedNumbers {
            let todo = todos[number - 1]
            print(todo.format())
            
            // Archive the todo
            let archivedItem = ArchivedTodoItem(todo: todo, reason: .deleted)
            archive.append(archivedItem)
            
            // Remove from active todos
            todos.remove(at: number - 1)
        }
        
        try Todo.storage.writeTodos(todos)
        try Todo.storage.writeArchive(archive)
        
        // Show summary and next steps
        if numbers.count > 1 {
            print("\n🗑️ Removed \(numbers.count) todos.")
        } else {
            print("\n🗑️ Todo removed.")
        }
        
        if !todos.isEmpty {
            print("\n📝 Next steps:")
            print("• List remaining todos: todo list")
            print("• View todo statistics: todo stats --archived")
        } else {
            print("\n📝 All todos removed. Add a new one with: todo add \"task name\"")
        }
    }
} 