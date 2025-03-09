import ArgumentParser
import Foundation

struct ArchiveCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "archive",
        abstract: "Look back at your completed tasks 📚"
    )
    
    @Flag(name: [.customShort("p"), .long], help: "Arrange tasks by importance")
    var byPriority = false
    
    @Flag(name: [.customShort("d"), .long], help: "Arrange tasks by when they were completed")
    var byDate = false
    
    @Option(name: .shortAndLong, help: "Show tasks with a specific tag")
    var tag: String?
    
    @Option(name: .shortAndLong, help: "Show tasks by how they were archived (completed/deleted/expired)")
    var reason: String?
    
    @Flag(name: .shortAndLong, help: "Turn off colorful output")
    var noColor = false
    
    @Flag(name: .shortAndLong, help: "Create a pretty web page of your archived tasks")
    var html = false
    
    @Option(name: [.customShort("f"), .long], help: "Save the web page to a file")
    var outputFile: String?
    
    func run() throws {
        var archive = try Todo.storage.readArchive()
        
        // Apply filters
        if let tag = tag {
            archive = archive.filter { $0.todo.tags.contains(tag) }
        }
        
        if let reason = reason {
            guard let archiveReason = ArchiveReason(rawValue: reason.lowercased()) else {
                throw ValidationError("I don't recognize that archive reason. You can use: 'completed', 'deleted', or 'expired' 🤔")
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
            print("No completed tasks yet! Keep going, you'll get there! 💪")
            return
        }
        
        if let outputFile = outputFile {
            var fileOutput = ""
            if html {
                fileOutput = HTMLFormatter.formatArchive(archive)
            } else {
                for (index, todo) in archive.enumerated() {
                    fileOutput += todo.format(index: index + 1, colored: false) + "\n"
                }
            }
            try fileOutput.write(to: URL(fileURLWithPath: outputFile), atomically: true, encoding: .utf8)
            print("Output written to \(outputFile)")
        } else {
            if html {
                print(HTMLFormatter.formatArchive(archive))
            } else {
                for (index, todo) in archive.enumerated() {
                    print(todo.format(index: index + 1, colored: !noColor))
                }
            }
        }
    }
} 