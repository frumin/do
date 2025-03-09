import Foundation

struct TodoStorage {
    private let todoFile: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(filePath: URL? = nil) {
        self.todoFile = filePath ?? FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".todo")
            .appendingPathExtension("json")
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
    
    func deleteTodoFile() throws {
        if FileManager.default.fileExists(atPath: todoFile.path) {
            try FileManager.default.removeItem(at: todoFile)
        }
    }
} 