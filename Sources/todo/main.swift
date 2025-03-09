// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ArgumentParser

struct Todo: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "todo",
        abstract: "A simple todo manager",
        subcommands: [Add.self, List.self, Done.self, Remove.self]
    )
    
    private static let todoFile = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".todo")
        .appendingPathExtension("txt")
    
    static func readTodos() throws -> [String] {
        if !FileManager.default.fileExists(atPath: todoFile.path) {
            try "".write(to: todoFile, atomically: true, encoding: .utf8)
        }
        let content = try String(contentsOf: todoFile, encoding: .utf8)
        return content.split(separator: "\n").map(String.init)
    }
    
    static func writeTodos(_ todos: [String]) throws {
        let content = todos.joined(separator: "\n")
        try content.write(to: todoFile, atomically: true, encoding: .utf8)
    }
}

// Add a new todo
extension Todo {
    struct Add: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Add a new todo item"
        )
        
        @Argument(help: "The todo item to add")
        var item: [String]
        
        func run() throws {
            var todos = try Todo.readTodos()
            todos.append(item.joined(separator: " "))
            try Todo.writeTodos(todos)
        }
    }
}

// List all todos
extension Todo {
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "List all todo items"
        )
        
        func run() throws {
            let todos = try Todo.readTodos()
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
    struct Done: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Mark a todo item as done"
        )
        
        @Argument(help: "The number of the todo item to mark as done")
        var number: Int
        
        func run() throws {
            var todos = try Todo.readTodos()
            guard number > 0 && number <= todos.count else {
                throw ValidationError("Invalid todo number")
            }
            todos.remove(at: number - 1)
            try Todo.writeTodos(todos)
        }
    }
}

// Remove a todo
extension Todo {
    struct Remove: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Remove a todo item"
        )
        
        @Argument(help: "The number of the todo item to remove")
        var number: Int
        
        func run() throws {
            var todos = try Todo.readTodos()
            guard number > 0 && number <= todos.count else {
                throw ValidationError("Invalid todo number")
            }
            todos.remove(at: number - 1)
            try Todo.writeTodos(todos)
        }
    }
}

Todo.main()
