import ArgumentParser
import Foundation
import TodoKit

struct StatsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "stats",
        abstract: "Show todo statistics 📊"
    )
    
    @Flag(name: [.customShort("a"), .long], help: "Include archived todos")
    var includeArchived = false
    
    @Flag(name: [.customShort("t"), .long], help: "Show tag statistics")
    var showTags = false
    
    @Flag(name: [.customShort("m"), .long], help: "Output in HTML format")
    var html = false
    
    mutating func run() throws {
        var stats = TodoStats()
        let todos = try Todo.storage.readTodos()
        stats.add(todos: todos)
        
        if includeArchived {
            let archived = try Todo.storage.readArchive()
            stats.add(archived: archived)
        }
        
        if html {
            print(HTMLFormatter.formatStats(stats))
        } else {
            // Basic stats
            print("📊 Todo Statistics:")
            print("-------------------")
            print("Total todos: \(stats.totalTodos)")
            print("Active todos: \(stats.activeTodos)")
            if includeArchived {
                print("Archived todos: \(stats.archivedTodos)")
                print("  - Completed: \(stats.completedTodos)")
                print("  - Deleted: \(stats.deletedTodos)")
            }
            
            // Priority stats
            print("\nPriority breakdown:")
            print("  High: \(stats.highPriorityTodos)")
            print("  Medium: \(stats.mediumPriorityTodos)")
            print("  Low: \(stats.lowPriorityTodos)")
            print("  None: \(stats.noPriorityTodos)")
            
            // Due date stats
            print("\nDue date stats:")
            print("  Overdue: \(stats.overdueTodos)")
            print("  Due today: \(stats.dueTodayTodos)")
            print("  Due this week: \(stats.dueThisWeekTodos)")
            print("  No due date: \(stats.noDueDateTodos)")
            
            // Tag stats
            if showTags {
                print("\nTag statistics:")
                let sortedTags = stats.tagCounts.sorted { $0.value > $1.value }
                for (tag, count) in sortedTags {
                    print("  #\(tag): \(count)")
                }
            }
        }
    }
}

struct TodoStats {
    var totalTodos = 0
    var activeTodos = 0
    var archivedTodos = 0
    var completedTodos = 0
    var deletedTodos = 0
    
    var highPriorityTodos = 0
    var mediumPriorityTodos = 0
    var lowPriorityTodos = 0
    var noPriorityTodos = 0
    
    var overdueTodos = 0
    var dueTodayTodos = 0
    var dueThisWeekTodos = 0
    var noDueDateTodos = 0
    
    var tagCounts: [String: Int] = [:]
    
    mutating func add(todos: [Todo]) {
        activeTodos += todos.count
        totalTodos += todos.count
        
        for todo in todos {
            // Priority stats
            switch todo.priority {
            case .high: highPriorityTodos += 1
            case .medium: mediumPriorityTodos += 1
            case .low: lowPriorityTodos += 1
            case .none: noPriorityTodos += 1
            }
            
            // Due date stats
            if let dueDate = todo.dueDate {
                if todo.isOverdue {
                    overdueTodos += 1
                } else if Calendar.current.isDateInToday(dueDate) {
                    dueTodayTodos += 1
                } else if Calendar.current.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear) {
                    dueThisWeekTodos += 1
                }
            } else {
                noDueDateTodos += 1
            }
            
            // Tag stats
            for tag in todo.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
    }
    
    mutating func add(archived: [ArchivedTodoItem]) {
        archivedTodos += archived.count
        totalTodos += archived.count
        
        for item in archived {
            switch item.reason {
            case .completed: completedTodos += 1
            case .deleted: deletedTodos += 1
            case .expired: break // We don't track expired todos separately
            }
            
            // Tag stats
            for tag in item.todo.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
    }
} 