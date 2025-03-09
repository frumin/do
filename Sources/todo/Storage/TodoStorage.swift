import Foundation

struct TodoStorage {
    private let todoFile: URL
    
    init(filePath: URL? = nil) {
        self.todoFile = filePath ?? FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".todo")
            .appendingPathExtension("txt")
    }
    
    func readTodos() throws -> [String] {
        if !FileManager.default.fileExists(atPath: todoFile.path) {
            try "".write(to: todoFile, atomically: true, encoding: .utf8)
        }
        let content = try String(contentsOf: todoFile, encoding: .utf8)
        return content.split(separator: "\n").map(String.init)
    }
    
    func writeTodos(_ todos: [String]) throws {
        let content = todos.joined(separator: "\n")
        try content.write(to: todoFile, atomically: true, encoding: .utf8)
    }
    
    func deleteTodoFile() throws {
        if FileManager.default.fileExists(atPath: todoFile.path) {
            try FileManager.default.removeItem(at: todoFile)
        }
    }
} 