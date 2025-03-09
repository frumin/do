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
        let totalCount = todos.count
        var appliedFilters: [String] = []
        
        // Apply filters
        if overdue {
            todos = todos.filter { $0.isOverdue }
            appliedFilters.append("overdue")
        }
        
        if noDueDate {
            todos = todos.filter { $0.dueDate == nil }
            appliedFilters.append("no due date")
        }
        
        if withDueDate {
            todos = todos.filter { $0.dueDate != nil }
            appliedFilters.append("with due date")
        }
        
        if withTags {
            todos = todos.filter { !$0.tags.isEmpty }
            appliedFilters.append("with tags")
        }
        
        if withoutTags {
            todos = todos.filter { $0.tags.isEmpty }
            appliedFilters.append("without tags")
        }
        
        if let tag = tag {
            todos = todos.filter { $0.tags.contains(tag) }
            appliedFilters.append("tagged #\(tag)")
        }
        
        // Apply sorting
        if byPriority {
            todos.sort { $0.priority.sortValue < $1.priority.sortValue }
            appliedFilters.append("sorted by priority")
        } else if byDate {
            todos.sort { 
                guard let date1 = $0.dueDate else { return false }
                guard let date2 = $1.dueDate else { return true }
                return date1 < date2
            }
            appliedFilters.append("sorted by due date")
        }
        
        // Output
        if html {
            print(HTMLFormatter.format(todos))
            return
        }
        
        print("\n📝 Your todos:")
        print("─────────────")
        if !todos.isEmpty {
            print(Todo.format(todos, showNumbers: true))
            
            // Show summary
            let filteredCount = todos.count
            if !appliedFilters.isEmpty {
                print("\nShowing \(filteredCount) of \(totalCount) todos (\(appliedFilters.joined(separator: ", ")))")
            }
            
            // Show stats
            let overdueTodos = todos.filter { $0.isOverdue }.count
            let dueTodayTodos = todos.filter { 
                guard let dueDate = $0.dueDate else { return false }
                return Calendar.current.isDateInToday(dueDate)
            }.count
            
            if overdueTodos > 0 || dueTodayTodos > 0 {
                print("\nStatus:")
                if overdueTodos > 0 {
                    print("• \(overdueTodos) overdue")
                }
                if dueTodayTodos > 0 {
                    print("• \(dueTodayTodos) due today")
                }
            }
            
            // Show helpful tips
            print("\n💡 Tips:")
            print("• Add a new todo: todo add \"task name\"")
            print("• Mark as done: todo done <number>")
            if !byPriority && todos.count > 1 {
                print("• Sort by priority: todo list --by-priority")
            }
            if !byDate && todos.count > 1 {
                print("• Sort by due date: todo list --by-date")
            }
        } else {
            if totalCount == 0 {
                print("No todos yet! Add one with: todo add \"task name\"")
            } else {
                print("No matching todos found.")
                if !appliedFilters.isEmpty {
                    print("Filters applied: \(appliedFilters.joined(separator: ", "))")
                }
                print("\nTry:")
                print("• List all todos: todo list")
                print("• Add a new todo: todo add \"task name\"")
            }
        }
    }
} 