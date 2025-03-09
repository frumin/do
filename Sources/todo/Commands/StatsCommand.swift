import ArgumentParser
import Foundation

struct StatsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "stats",
        abstract: "Show todo statistics"
    )
    
    @Flag(name: .shortAndLong, help: "Include archived todos in stats")
    var includeArchived = false
    
    @Flag(name: .shortAndLong, help: "Show detailed tag statistics")
    var tags = false
    
    @Flag(name: .shortAndLong, help: "Disable colored output")
    var noColor = false
    
    @Flag(name: .shortAndLong, help: "Output as HTML")
    var html = false
    
    @Option(name: [.customShort("f"), .long], help: "Output HTML to file")
    var outputFile: String?
    
    func run() throws {
        let todos = try Todo.storage.readTodos()
        let archived = includeArchived ? try Todo.storage.readArchive() : []
        
        // Basic stats
        var output = ""
        let activeCount = todos.count
        let archivedCount = archived.count
        let totalCount = activeCount + archivedCount
        
        // Priority stats
        let highPriority = todos.filter { $0.priority == .high }.count
        let mediumPriority = todos.filter { $0.priority == .medium }.count
        let lowPriority = todos.filter { $0.priority == .low }.count
        let noPriority = todos.filter { $0.priority == .none }.count
        
        // Due date stats
        let withDueDate = todos.filter { $0.dueDate != nil }.count
        let overdue = todos.filter { $0.isOverdue }.count
        let dueSoon = todos.filter { 
            guard let dueDate = $0.dueDate else { return false }
            return dueDate > Date() && dueDate <= Date().addingTimeInterval(7 * 24 * 3600)
        }.count
        
        // Tag stats
        let withTags = todos.filter { !$0.tags.isEmpty }.count
        let allTags = todos.reduce(into: [String: Int]()) { dict, todo in
            for tag in todo.tags {
                dict[tag, default: 0] += 1
            }
        }
        
        // Archive stats
        let completedCount = archived.filter { $0.reason == .completed }.count
        let deletedCount = archived.filter { $0.reason == .deleted }.count
        let expiredCount = archived.filter { $0.reason == .expired }.count
        
        if html {
            output = HTMLFormatter.formatStats(
                activeCount: activeCount,
                archivedCount: archivedCount,
                highPriority: highPriority,
                mediumPriority: mediumPriority,
                lowPriority: lowPriority,
                noPriority: noPriority,
                withDueDate: withDueDate,
                overdue: overdue,
                dueSoon: dueSoon,
                withTags: withTags,
                allTags: allTags,
                completedCount: completedCount,
                deletedCount: deletedCount,
                expiredCount: expiredCount
            )
        } else {
            // Basic stats
            output += "Todo Statistics:\n"
            output += "═══════════════\n\n"
            
            output += "Counts:\n"
            output += "  Active todos: \(activeCount)\n"
            if includeArchived {
                output += "  Archived todos: \(archivedCount)\n"
                output += "  Total todos: \(totalCount)\n"
            }
            output += "\n"
            
            // Priority distribution
            output += "Priorities:\n"
            output += formatPriorityBar(high: highPriority, medium: mediumPriority, low: lowPriority, none: noPriority, colored: !noColor)
            output += "  High: \(highPriority)\n"
            output += "  Medium: \(mediumPriority)\n"
            output += "  Low: \(lowPriority)\n"
            output += "  None: \(noPriority)\n\n"
            
            // Due dates
            output += "Due Dates:\n"
            output += "  With due date: \(withDueDate)\n"
            output += "  Overdue: \(overdue)\n"
            output += "  Due within 7 days: \(dueSoon)\n\n"
            
            // Tags
            output += "Tags:\n"
            output += "  With tags: \(withTags)\n"
            if tags && !allTags.isEmpty {
                output += "  Most used tags:\n"
                let sortedTags = allTags.sorted { $0.value > $1.value }
                for (tag, count) in sortedTags.prefix(5) {
                    output += "    #\(tag): \(count)\n"
                }
                output += "\n"
            }
            
            // Archive stats
            if includeArchived {
                output += "Archive:\n"
                output += "  Completed: \(completedCount)\n"
                output += "  Deleted: \(deletedCount)\n"
                output += "  Expired: \(expiredCount)\n"
            }
        }
        
        if let outputFile = outputFile {
            try output.write(to: URL(fileURLWithPath: outputFile), atomically: true, encoding: .utf8)
            print("Output written to \(outputFile)")
        } else {
            print(output)
        }
    }
    
    private func formatPriorityBar(high: Int, medium: Int, low: Int, none: Int, colored: Bool) -> String {
        let total = high + medium + low + none
        guard total > 0 else { return "  No todos\n" }
        
        let width = 30
        let highWidth = width * high / total
        let mediumWidth = width * medium / total
        let lowWidth = width * low / total
        let noneWidth = width - highWidth - mediumWidth - lowWidth
        
        let reset = "\u{001B}[0m"
        var bar = "  "
        
        if colored {
            bar += "\u{001B}[41m" + String(repeating: "█", count: highWidth) + reset // Red for high
            bar += "\u{001B}[43m" + String(repeating: "█", count: mediumWidth) + reset // Yellow for medium
            bar += "\u{001B}[42m" + String(repeating: "█", count: lowWidth) + reset // Green for low
            bar += "\u{001B}[47m" + String(repeating: "█", count: noneWidth) + reset // White for none
        } else {
            bar += String(repeating: "H", count: highWidth)
            bar += String(repeating: "M", count: mediumWidth)
            bar += String(repeating: "L", count: lowWidth)
            bar += String(repeating: "-", count: noneWidth)
        }
        
        bar += "\n"
        return bar
    }
} 