// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import Foundation

struct Todo: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "todo",
        abstract: "A simple todo manager",
        subcommands: [
            AddCommand.self,
            ListCommand.self,
            DoneCommand.self,
            RemoveCommand.self
        ]
    )
    
    static var storage = TodoStorage()
}

// Add a new todo
extension Todo {
    struct AddCommand: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Add a new todo item"
        )
        
        @Argument(help: "The todo item to add")
        var item: [String]
        
        func run() throws {
            var todos = try Todo.storage.readTodos()
            todos.append(item.joined(separator: " "))
            try Todo.storage.writeTodos(todos)
        }
    }
}

// List all todos
extension Todo {
    struct ListCommand: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "List all todo items"
        )
        
        func run() throws {
            let todos = try Todo.storage.readTodos()
            for (index, todo) in todos.enumerated() {
                print("\(index + 1). \(todo)")
            }
            if todos.isEmpty {
                print("No todos yet!")
            }
        }
    }
}

// Mark a todo as done
extension Todo {
    struct DoneCommand: ParsableCommand {
        static var configuration = CommandConfiguration(
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
}

// Remove a todo
extension Todo {
    struct RemoveCommand: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Remove a todo item"
        )
        
        @Argument(help: "The number of the todo item to remove")
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
}

Todo.main()
