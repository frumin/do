import Foundation
import TodoKit

struct HTMLFormatter {
    static func format(_ todos: [Todo]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>Todo List</title>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    max-width: 800px;
                    margin: 2rem auto;
                    padding: 0 1rem;
                    line-height: 1.5;
                }
                .todo {
                    border: 1px solid #ddd;
                    border-radius: 4px;
                    padding: 1rem;
                    margin-bottom: 1rem;
                }
                .high { border-left: 4px solid #ff4444; }
                .medium { border-left: 4px solid #ffbb33; }
                .low { border-left: 4px solid #00C851; }
                .overdue { color: #ff4444; }
                .tag {
                    display: inline-block;
                    background: #eee;
                    padding: 0.2rem 0.5rem;
                    border-radius: 4px;
                    margin-right: 0.5rem;
                    font-size: 0.9rem;
                }
                .meta {
                    color: #666;
                    font-size: 0.9rem;
                    margin-top: 0.5rem;
                }
            </style>
        </head>
        <body>
            <h1>Todo List</h1>
        """
        
        for (index, todo) in todos.enumerated() {
            let priorityClass = todo.priority == .none ? "" : " \(todo.priority)"
            html += """
            <div class="todo\(priorityClass)">
                <strong>\(index + 1).</strong> \(todo.title)
            """
            
            if !todo.tags.isEmpty {
                html += "<div>"
                for tag in todo.tags {
                    html += "<span class=\"tag\">#\(tag)</span>"
                }
                html += "</div>"
            }
            
            if let dueDate = todo.dueDate {
                let dueDateClass = todo.isOverdue ? " overdue" : ""
                html += "<div class=\"meta\(dueDateClass)\">Due: \(dateFormatter.string(from: dueDate))</div>"
            }
            
            html += "</div>"
        }
        
        html += """
        </body>
        </html>
        """
        
        return html
    }
    
    static func formatArchive(_ archive: [ArchivedTodoItem]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Archived Todos</title>
            <style>
                /* Reuse existing styles */
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
                    max-width: 800px;
                    margin: 2rem auto;
                    padding: 0 1rem;
                    background: #f5f5f5;
                }
                .todo-list {
                    background: white;
                    border-radius: 8px;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                    overflow: hidden;
                }
                .todo-item {
                    padding: 1rem;
                    border-bottom: 1px solid #eee;
                    display: flex;
                    align-items: center;
                    gap: 0.5rem;
                }
                .todo-item:last-child {
                    border-bottom: none;
                }
                .priority {
                    font-size: 1.2rem;
                    width: 24px;
                }
                .priority-high { color: #dc3545; }
                .priority-medium { color: #ffc107; }
                .priority-low { color: #28a745; }
                .title {
                    flex: 1;
                    font-size: 1rem;
                }
                .due-date {
                    color: #0d6efd;
                    font-size: 0.9rem;
                }
                .due-date.overdue {
                    color: #dc3545;
                }
                .tags {
                    display: flex;
                    gap: 0.5rem;
                    flex-wrap: wrap;
                }
                .tag {
                    background: #e9ecef;
                    color: #495057;
                    padding: 0.2rem 0.5rem;
                    border-radius: 4px;
                    font-size: 0.8rem;
                }
                .archive-info {
                    display: flex;
                    gap: 1rem;
                    font-size: 0.9rem;
                    color: #6c757d;
                }
                .archive-reason {
                    text-transform: uppercase;
                    font-weight: 500;
                }
                h1 {
                    color: #212529;
                    margin-bottom: 1.5rem;
                }
            </style>
        </head>
        <body>
            <h1>Archived Todos</h1>
            <div class="todo-list">
        """
        
        let archivedItems = archive.enumerated().map { (index, archived) -> String in
            let todo = archived.todo
            let priorityClass = switch todo.priority {
                case .high: "priority-high"
                case .medium: "priority-medium"
                case .low: "priority-low"
                case .none: ""
            }
            
            let prioritySymbol = todo.priority.symbol
            
            var dueDateHtml = ""
            if let dueDate = todo.dueDate {
                dueDateHtml = """
                    <span class="due-date">
                        📅 \(dateFormatter.string(from: dueDate))
                    </span>
                """
            }
            
            let tagsHtml = todo.tags.isEmpty ? "" : """
                <div class="tags">
                    \(todo.tags.map { "<span class=\"tag\">#\($0)</span>" }.joined())
                </div>
            """
            
            return """
                <div class="todo-item">
                    <span class="priority \(priorityClass)">\(prioritySymbol)</span>
                    <span class="title">\(todo.title)</span>
                    \(dueDateHtml)
                    \(tagsHtml)
                    <div class="archive-info">
                        <span class="archive-reason">\(archived.reason.rawValue)</span>
                        <span class="archive-date">Archived \(dateFormatter.string(from: archived.archivedAt))</span>
                    </div>
                </div>
            """
        }.joined(separator: "\n")
        
        return html + archivedItems + """
            </div>
        </body>
        </html>
        """
    }
    
    static func formatStats(_ stats: TodoStats) -> String {
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>Todo Statistics</title>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    max-width: 800px;
                    margin: 2rem auto;
                    padding: 0 1rem;
                    line-height: 1.5;
                }
                .stat-group {
                    border: 1px solid #ddd;
                    border-radius: 4px;
                    padding: 1rem;
                    margin-bottom: 1rem;
                }
                .stat-row {
                    display: flex;
                    justify-content: space-between;
                    margin: 0.5rem 0;
                }
                .stat-label {
                    color: #666;
                }
                .stat-value {
                    font-weight: bold;
                }
                .priority-bar {
                    height: 20px;
                    border-radius: 10px;
                    overflow: hidden;
                    display: flex;
                    margin: 1rem 0;
                }
                .priority-high { background: #ff4444; }
                .priority-medium { background: #ffbb33; }
                .priority-low { background: #00C851; }
                .priority-none { background: #eee; }
                .tag-cloud {
                    display: flex;
                    flex-wrap: wrap;
                    gap: 0.5rem;
                }
                .tag {
                    background: #eee;
                    padding: 0.2rem 0.5rem;
                    border-radius: 4px;
                    font-size: 0.9rem;
                }
            </style>
        </head>
        <body>
            <h1>Todo Statistics</h1>
            
            <div class="stat-group">
                <h2>Overview</h2>
                <div class="stat-row">
                    <span class="stat-label">Total todos:</span>
                    <span class="stat-value">\(stats.totalTodos)</span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Active todos:</span>
                    <span class="stat-value">\(stats.activeTodos)</span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Archived todos:</span>
                    <span class="stat-value">\(stats.archivedTodos)</span>
                </div>
            </div>
            
            <div class="stat-group">
                <h2>Priority Distribution</h2>
                <div class="priority-bar">
        """
        
        if stats.totalTodos > 0 {
            let highPercent = Float(stats.highPriorityTodos) / Float(stats.totalTodos) * 100
            let mediumPercent = Float(stats.mediumPriorityTodos) / Float(stats.totalTodos) * 100
            let lowPercent = Float(stats.lowPriorityTodos) / Float(stats.totalTodos) * 100
            let nonePercent = Float(stats.noPriorityTodos) / Float(stats.totalTodos) * 100
            
            html += """
                    <div class="priority-high" style="width: \(highPercent)%"></div>
                    <div class="priority-medium" style="width: \(mediumPercent)%"></div>
                    <div class="priority-low" style="width: \(lowPercent)%"></div>
                    <div class="priority-none" style="width: \(nonePercent)%"></div>
            """
        }
        
        html += """
                </div>
                <div class="stat-row">
                    <span class="stat-label">High priority:</span>
                    <span class="stat-value">\(stats.highPriorityTodos)</span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Medium priority:</span>
                    <span class="stat-value">\(stats.mediumPriorityTodos)</span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Low priority:</span>
                    <span class="stat-value">\(stats.lowPriorityTodos)</span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">No priority:</span>
                    <span class="stat-value">\(stats.noPriorityTodos)</span>
                </div>
            </div>
            
            <div class="stat-group">
                <h2>Due Dates</h2>
                <div class="stat-row">
                    <span class="stat-label">Overdue:</span>
                    <span class="stat-value">\(stats.overdueTodos)</span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Due today:</span>
                    <span class="stat-value">\(stats.dueTodayTodos)</span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Due this week:</span>
                    <span class="stat-value">\(stats.dueThisWeekTodos)</span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">No due date:</span>
                    <span class="stat-value">\(stats.noDueDateTodos)</span>
                </div>
            </div>
            
            <div class="stat-group">
                <h2>Tags</h2>
                <div class="tag-cloud">
        """
        
        let sortedTags = stats.tagCounts.sorted { $0.value > $1.value }
        for (tag, count) in sortedTags {
            html += "<div class=\"tag\">#\(tag) (\(count))</div>"
        }
        
        html += """
                </div>
            </div>
        </body>
        </html>
        """
        
        return html
    }
} 