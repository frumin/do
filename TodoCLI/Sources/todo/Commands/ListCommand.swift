import Foundation
import ArgumentParser
import TodoKit

struct ListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List your todos 📝"
    )
    
    @Flag(name: [.customShort("p"), .long], help: "Sort by priority")
    var byPriority = false
    
    @Flag(name: [.customShort("d"), .long], help: "Sort by due date")
    var byDate = false
    
    @Flag(name: [.customShort("o"), .long], help: "Show overdue tasks only")
    var overdue = false
    
    @Flag(name: [.customShort("n"), .long], help: "Show tasks with no due date")
    var noDueDate = false
    
    @Flag(name: [.customShort("w"), .long], help: "Show tasks with due date")
    var withDueDate = false
    
    @Flag(name: [.customShort("t"), .long], help: "Show tasks with tags")
    var withTags = false
    
    @Flag(name: [.customShort("u"), .long], help: "Show tasks without tags")
    var withoutTags = false
    
    @Option(name: [.customShort("g"), .long], help: "Filter by tag")
    var tag: String?
    
    @Flag(name: [.customShort("m"), .long], help: "Output in HTML format")
    var html = false
    
    @Flag(name: [.customShort("c"), .long], help: "Don't use colors in output")
    var noColor = false
    
    mutating func run() throws {
        var todos = try Todo.storage.readTodos()
        
        // Apply filters
        if overdue {
            todos = todos.filter { $0.isOverdue }
        }
        
        if noDueDate {
            todos = todos.filter { $0.dueDate == nil }
        }
        
        if withDueDate {
            todos = todos.filter { $0.dueDate != nil }
        }
        
        if withTags {
            todos = todos.filter { !$0.tags.isEmpty }
        }
        
        if withoutTags {
            todos = todos.filter { $0.tags.isEmpty }
        }
        
        if let tag = tag {
            todos = todos.filter { $0.tags.contains(tag) }
        }
        
        // Apply sorting
        if byPriority {
            todos.sort { $0.priority.rawValue < $1.priority.rawValue }
        } else if byDate {
            todos.sort { 
                guard let date1 = $0.dueDate else { return false }
                guard let date2 = $1.dueDate else { return true }
                return date1 < date2
            }
        }
        
        // Output
        if html {
            print(HTMLFormatter.format(todos))
        } else {
            print(Todo.format(todos, showNumbers: true))
        }
    }
} 