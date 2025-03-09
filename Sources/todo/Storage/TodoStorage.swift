import Foundation

struct TodoStorage {
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