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
        
        // Remove todos in descending order
        for number in sortedNumbers {
            let todo = todos[number - 1]
            print(todo.format())
            
            // Archive the todo
            let archivedItem = ArchivedTodoItem(todo: todo, reason: .completed)
            archive.append(archivedItem)
            
            // Remove from active todos
            todos.remove(at: number - 1)
        }
        
        try Todo.storage.writeTodos(todos)
        try Todo.storage.writeArchive(archive)
        
        // Show summary and next steps
        if numbers.count > 1 {
            print("\n🎉 Completed \(numbers.count) todos!")
        } else {
            print("\n🎉 Todo completed!")
        }
        
        if !todos.isEmpty {
            print("\n📝 Next steps:")
            print("• List remaining todos: todo list")
            print("• View todo statistics: todo stats --archived")
        } else {
            print("\n🎯 All done! Add a new todo with: todo add \"task name\"")
        }
    }
} 