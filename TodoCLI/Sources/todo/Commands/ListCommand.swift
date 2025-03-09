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
            todos.sort { (a: Todo, b: Todo) -> Bool in
                a.priority.sortValue < b.priority.sortValue
            }
            appliedFilters.append("sorted by priority")
        } else if byDate {
            todos.sort { (a: Todo, b: Todo) -> Bool in
                guard let date1 = a.dueDate else { return false }
                guard let date2 = b.dueDate else { return true }
                return date1 < date2
            }
            appliedFilters.append("sorted by due date")
        }
        
        // Output
        if html {
            print(HTMLFormatter.format(todos))
            return
        }
        
        if todos.isEmpty {
            print("\n📝 No todos yet!")
            print("────────────────")
            print("Get started with:")
            print("• Add your first todo: todo add \"task name\"")
            print("• Get help: todo --help")
            return
        }

        let filteredTodos = todos
        let filteredCount = filteredTodos.count
        let overdueTodos = filteredTodos.filter { $0.isOverdue }.count
        let dueTodayTodos = filteredTodos.filter { 
            guard let dueDate = $0.dueDate else { return false }
            return Calendar.current.isDateInToday(dueDate)
        }.count
        
        print("\n📝 Your todos:")
        print("─────────────")
        
        print(Todo.format(filteredTodos, showNumbers: true))
        
        if filteredCount != totalCount {
            print("\nℹ️  Showing \(filteredCount) of \(totalCount) todos")
            print("   Filters: \(appliedFilters.joined(separator: ", "))")
        }

        // Only show status if we have todos
        if !filteredTodos.isEmpty {
            print("\n📊 Status:")
            if overdueTodos > 0 {
                print("• \(overdueTodos) overdue")
            }
            if dueTodayTodos > 0 {
                print("• \(dueTodayTodos) due today")
            }
        }

        print("\n💡 Quick tips:")
        print("• Add todo: todo add \"task name\"")
        print("• Complete todo: todo done <number>")
        print("• Sort by priority: todo list --by-priority")
        print("• Sort by due date: todo list --by-date")
        print("• View all commands: todo --help")
    }
} 