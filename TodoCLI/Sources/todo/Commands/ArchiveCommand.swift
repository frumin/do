import ArgumentParser
import Foundation
import TodoKit

struct ArchiveCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "archive",
        abstract: "View archived todos 📦"
    )
    
    @Flag(name: .shortAndLong, help: "Sort by priority")
    var byPriority = false
    
    @Flag(name: .shortAndLong, help: "Sort by archive date")
    var byDate = false
    
    @Flag(name: .shortAndLong, help: "Show completed tasks only")
    var completed = false
    
    @Flag(name: .shortAndLong, help: "Show deleted tasks only")
    var deleted = false
    
    @Flag(name: .shortAndLong, help: "Show expired tasks only")
    var expired = false
    
    @Flag(name: .shortAndLong, help: "Output in HTML format")
    var html = false
    
    @Flag(name: .shortAndLong, help: "Don't use colors in output")
    var noColor = false
    
    mutating func run() throws {
        var archive = try Todo.storage.readArchive()
        
        // Apply filters
        if completed {
            archive = archive.filter { $0.reason == .completed }
        }
        
        if deleted {
            archive = archive.filter { $0.reason == .deleted }
        }
        
        if expired {
            archive = archive.filter { $0.reason == .expired }
        }
        
        // Apply sorting
        if byPriority {
            archive.sort { $0.todo.priority.sortValue < $1.todo.priority.sortValue }
        } else if byDate {
            archive.sort { $0.archivedAt > $1.archivedAt }
        }
        
        if archive.isEmpty {
            print("\n📂 Archive is empty")
            print("─────────────────")
            print("Complete or remove todos to see them here.")
            print("\n💡 Quick actions:")
            print("• View active todos: todo list")
            print("• Add new todo: todo add \"task name\"")
            return
        }

        if html {
            print(HTMLFormatter.format(archive.map { $0.todo }))
            return
        }

        print("\n📂 Archived todos:")
        print("────────────────")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        for (index, item) in archive.enumerated() {
            let gray = noColor ? "" : "\u{001B}[90m"
            let reset = noColor ? "" : "\u{001B}[0m"
            print("\(gray)[\(item.reason.rawValue.uppercased())] \(item.todo.format(index: index + 1))")
            print("  Archived: \(dateFormatter.string(from: item.archivedAt))\(reset)")
        }

        print("\n💡 Quick actions:")
        print("• View active todos: todo list")
        print("• Add new todo: todo add \"task name\"")
        print("• See statistics: todo stats")
    }
} 