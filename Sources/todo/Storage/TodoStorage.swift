import Foundation

struct TodoStorage {
    private let todoFile: URL
    private let archiveFile: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(filePath: URL? = nil) {
        let baseURL = filePath ?? FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".todo")
        
        self.todoFile = baseURL.appendingPathExtension("json")
        self.archiveFile = baseURL.appendingPathExtension("archive.json")
            
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.outputFormatting = .prettyPrinted
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func readTodos() throws -> [TodoItem] {
        if !FileManager.default.fileExists(atPath: todoFile.path) {
            try "[]".write(to: todoFile, atomically: true, encoding: .utf8)
            return []
        }
        let data = try Data(contentsOf: todoFile)
        return try decoder.decode([TodoItem].self, from: data)
    }
    
    func writeTodos(_ todos: [TodoItem]) throws {
        let data = try encoder.encode(todos)
        try data.write(to: todoFile, options: .atomic)
    }
    
    func readArchive() throws -> [ArchivedTodoItem] {
        if !FileManager.default.fileExists(atPath: archiveFile.path) {
            try "[]".write(to: archiveFile, atomically: true, encoding: .utf8)
            return []
        }
        let data = try Data(contentsOf: archiveFile)
        return try decoder.decode([ArchivedTodoItem].self, from: data)
    }
    
    func writeArchive(_ todos: [ArchivedTodoItem]) throws {
        let data = try encoder.encode(todos)
        try data.write(to: archiveFile, options: .atomic)
    }
    
    func archiveTodo(_ todo: TodoItem, reason: ArchiveReason) throws {
        var todos = try readTodos()
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else {
            return
        }
        todos.remove(at: index)
        try writeTodos(todos)
        
        var archive = try readArchive()
        let archivedTodo = ArchivedTodoItem(
            todo: todo,
            archivedAt: Date(),
            reason: reason
        )
        archive.append(archivedTodo)
        try writeArchive(archive)
    }
    
    func deleteTodoFile() throws {
        if FileManager.default.fileExists(atPath: todoFile.path) {
            try FileManager.default.removeItem(at: todoFile)
        }
        if FileManager.default.fileExists(atPath: archiveFile.path) {
            try FileManager.default.removeItem(at: archiveFile)
        }
    }
} 