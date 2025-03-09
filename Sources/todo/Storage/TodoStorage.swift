import Foundation
import TodoKit

class TodoStorage {
    static let shared = TodoStorage()
    
    private let todoFile: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(todoFile: URL? = nil) {
        self.todoFile = todoFile ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".todo.json")
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
    
    func readTodos() throws -> [Todo] {
        if !FileManager.default.fileExists(atPath: todoFile.path) {
            try "[]".write(to: todoFile, atomically: true, encoding: .utf8)
        }
        
        let data = try Data(contentsOf: todoFile)
        return try decoder.decode([Todo].self, from: data)
    }
    
    func writeTodos(_ todos: [Todo]) throws {
        let data = try encoder.encode(todos)
        try data.write(to: todoFile, options: .atomic)
    }
    
    func readArchive() throws -> [ArchivedTodoItem] {
        let archiveFile = todoFile.deletingLastPathComponent().appendingPathComponent(".todo.archive.json")
        if !FileManager.default.fileExists(atPath: archiveFile.path) {
            try "[]".write(to: archiveFile, atomically: true, encoding: .utf8)
        }
        
        let data = try Data(contentsOf: archiveFile)
        return try decoder.decode([ArchivedTodoItem].self, from: data)
    }
    
    func archiveTodo(_ todo: Todo, reason: ArchiveReason) throws {
        var todos = try readTodos()
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else {
            return
        }
        
        todos.remove(at: index)
        try writeTodos(todos)
        
        let archivedItem = ArchivedTodoItem(todo: todo, archivedAt: Date(), reason: reason)
        var archive = try readArchive()
        archive.append(archivedItem)
        
        let archiveFile = todoFile.deletingLastPathComponent().appendingPathComponent(".todo.archive.json")
        let data = try encoder.encode(archive)
        try data.write(to: archiveFile, options: .atomic)
    }
} 