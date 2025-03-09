import ArgumentParser
import Foundation

struct ArchiveCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "archive",
        abstract: "View or manage archived todo items"
    )
    
    @Flag(name: [.customShort("p"), .long], help: "Sort by priority")
    var byPriority = false
    
    @Flag(name: [.customShort("d"), .long], help: "Sort by archive date")
    var byDate = false
    
    @Option(name: .shortAndLong, help: "Filter by tag")
    var tag: String?
    
    @Option(name: .shortAndLong, help: "Filter by archive reason (completed/deleted/expired)")
    var reason: String?
    
    @Flag(name: .shortAndLong, help: "Disable colored output")
    var noColor = false
    
    @Flag(name: .shortAndLong, help: "Output as HTML")
    var html = false
    
    @Option(name: [.customShort("f"), .long], help: "Output HTML to file")
    var outputFile: String?
    
    func run() throws {
        var archive = try Todo.storage.readArchive()
        
        // Apply filters
        if let tag = tag {
            archive = archive.filter { $0.todo.tags.contains(tag) }
        }
        
        if let reason = reason {
            guard let archiveReason = ArchiveReason(rawValue: reason.lowercased()) else {
                throw ValidationError("Invalid archive reason. Use: completed, deleted, or expired")
            }
            archive = archive.filter { $0.reason == archiveReason }
        }
        
        // Apply sorting
        if byPriority {
            archive.sort { $0.todo.priority < $1.todo.priority }
        } else if byDate {
            archive.sort { $0.archivedAt > $1.archivedAt }
        }
        
        if archive.isEmpty {
            print("No archived todos found!")
            return
        }
        
        if let outputFile = outputFile {
            var fileOutput = ""
            if html {
                // TODO: Implement HTML formatting for archived items
                fileOutput = "HTML output for archived items not implemented yet"
            } else {
                for (index, todo) in archive.enumerated() {
                    fileOutput += todo.format(index: index + 1, colored: false) + "\n"
                }
            }
            try fileOutput.write(to: URL(fileURLWithPath: outputFile), atomically: true, encoding: .utf8)
            print("Output written to \(outputFile)")
        } else {
            for (index, todo) in archive.enumerated() {
                print(todo.format(index: index + 1, colored: !noColor))
            }
        }
    }
} 