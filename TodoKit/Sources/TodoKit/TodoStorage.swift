import Foundation

public class TodoStorage {
    public static let shared = TodoStorage()
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var todosURL: URL {
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appURL = appSupportURL.appendingPathComponent("todo")
        try? fileManager.createDirectory(at: appURL, withIntermediateDirectories: true)
        return appURL.appendingPathComponent("todos.json")
    }
    
    private var archiveURL: URL {
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appURL = appSupportURL.appendingPathComponent("todo")
        try? fileManager.createDirectory(at: appURL, withIntermediateDirectories: true)
        return appURL.appendingPathComponent("archive.json")
    }
    
    private init() {}
    
    public func readTodos() throws -> [Todo] {
        guard fileManager.fileExists(atPath: todosURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: todosURL)
        return try decoder.decode([Todo].self, from: data)
    }
    
    public func writeTodos(_ todos: [Todo]) throws {
        let data = try encoder.encode(todos)
        try data.write(to: todosURL)
    }
    
    public func readArchive() throws -> [ArchivedTodoItem] {
        guard fileManager.fileExists(atPath: archiveURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: archiveURL)
        return try decoder.decode([ArchivedTodoItem].self, from: data)
    }
    
    public func writeArchive(_ items: [ArchivedTodoItem]) throws {
        let data = try encoder.encode(items)
        try data.write(to: archiveURL)
    }
    
    public func archiveTodo(_ todo: Todo, reason: ArchiveReason) throws {
        var todos = try readTodos()
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else {
            return
        }
        
        todos.remove(at: index)
        try writeTodos(todos)
        
        var archive = try readArchive()
        let archivedItem = ArchivedTodoItem(todo: todo, archivedAt: Date(), reason: reason)
        archive.append(archivedItem)
        try writeArchive(archive)
    }
    
    public func addTodo(_ todo: Todo) throws {
        var todos = try readTodos()
        todos.append(todo)
        try writeTodos(todos)
    }
    
    public func updateTodo(_ todo: Todo) throws {
        var todos = try readTodos()
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
            try writeTodos(todos)
        }
    }
    
    public func removeTodo(id: UUID) throws {
        var todos = try readTodos()
        todos.removeAll { $0.id == id }
        try writeTodos(todos)
    }
    
    public func deleteTodo(_ todo: Todo) throws {
        var todos = try readTodos()
        todos.removeAll { $0.id == todo.id }
        try writeTodos(todos)
    }
    
    public func observeChanges() -> AsyncStream<[Todo]> {
        AsyncStream { continuation in
            let _ = try? FileHandle(forReadingFrom: todosURL)
            Task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    if let todos = try? readTodos() {
                        continuation.yield(todos)
                    }
                }
            }
        }
    }
} 