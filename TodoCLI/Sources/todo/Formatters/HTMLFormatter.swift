import Foundation
import TodoKit

struct HTMLFormatter {
    static func format(_ todos: [Todo]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Todo List</title>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 20px;
                }
                .todo {
                    margin-bottom: 10px;
                    padding: 10px;
                    border-radius: 5px;
                    background-color: #f5f5f5;
                }
                .todo.high {
                    border-left: 5px solid #ff4444;
                }
                .todo.medium {
                    border-left: 5px solid #ffbb33;
                }
                .todo.low {
                    border-left: 5px solid #00C851;
                }
                .todo.none {
                    border-left: 5px solid #999999;
                }
                .todo-title {
                    font-weight: bold;
                    margin-bottom: 5px;
                }
                .todo-due {
                    color: #666;
                    font-size: 0.9em;
                }
                .todo-tags {
                    color: #666;
                    font-size: 0.9em;
                    margin-top: 5px;
                }
            </style>
        </head>
        <body>
        <h1>Todo List</h1>
        """
        
        for (index, todo) in todos.enumerated() {
            let priorityClass = todo.priority.rawValue
            html += """
            <div class="todo \(priorityClass)">
                <div class="todo-title">\(index + 1). \(todo.priority.symbol) \(todo.title)</div>
            """
            
            if let dueDate = todo.dueDate {
                html += """
                <div class="todo-due">Due: \(dateFormatter.string(from: dueDate))</div>
                """
            }
            
            if !todo.tags.isEmpty {
                html += """
                <div class="todo-tags">\(todo.formattedTags)</div>
                """
            }
            
            html += "</div>\n"
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
    
    static func formatStats(
        activeCount: Int,
        archivedCount: Int,
        highPriority: Int,
        mediumPriority: Int,
        lowPriority: Int,
        noPriority: Int,
        withDueDate: Int,
        overdue: Int,
        dueSoon: Int,
        withTags: Int,
        allTags: [String: Int],
        completedCount: Int,
        deletedCount: Int,
        expiredCount: Int
    ) -> String {
        let totalCount = activeCount + archivedCount
        let totalPriorities = highPriority + mediumPriority + lowPriority + noPriority
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Todo Statistics</title>
            <style>
                /* Reuse existing styles */
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
                    max-width: 800px;
                    margin: 2rem auto;
                    padding: 0 1rem;
                    background: #f5f5f5;
                }
                .stats-container {
                    background: white;
                    border-radius: 8px;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                    overflow: hidden;
                }
                .stats-section {
                    padding: 1rem;
                    border-bottom: 1px solid #eee;
                }
                .stats-section:last-child {
                    border-bottom: none;
                }
                .stats-section h2 {
                    margin: 0 0 1rem 0;
                    font-size: 1.2rem;
                    color: #212529;
                }
                .progress-bar {
                    height: 24px;
                    background: #e9ecef;
                    border-radius: 4px;
                    overflow: hidden;
                    margin: 0.5rem 0;
                }
                .progress-segment {
                    height: 100%;
                    float: left;
                }
                .progress-high { background: #dc3545; }
                .progress-medium { background: #ffc107; }
                .progress-low { background: #28a745; }
                .progress-none { background: #6c757d; }
                .stat-row {
                    display: flex;
                    justify-content: space-between;
                    margin: 0.25rem 0;
                }
                .tag-cloud {
                    display: flex;
                    flex-wrap: wrap;
                    gap: 0.5rem;
                    margin-top: 0.5rem;
                }
                .tag-stat {
                    background: #e9ecef;
                    color: #495057;
                    padding: 0.2rem 0.5rem;
                    border-radius: 4px;
                    font-size: 0.9rem;
                    display: flex;
                    align-items: center;
                    gap: 0.5rem;
                }
                .tag-count {
                    background: #dee2e6;
                    color: #495057;
                    padding: 0.1rem 0.4rem;
                    border-radius: 3px;
                    font-size: 0.8rem;
                }
                h1 {
                    color: #212529;
                    margin-bottom: 1.5rem;
                }
            </style>
        </head>
        <body>
            <h1>Todo Statistics</h1>
            <div class="stats-container">
                <div class="stats-section">
                    <h2>Overview</h2>
                    <div class="stat-row">
                        <span>Active todos:</span>
                        <span>\(activeCount)</span>
                    </div>
                    <div class="stat-row">
                        <span>Archived todos:</span>
                        <span>\(archivedCount)</span>
                    </div>
                    <div class="stat-row">
                        <span>Total todos:</span>
                        <span>\(totalCount)</span>
                    </div>
                </div>
                
                <div class="stats-section">
                    <h2>Priorities</h2>
                    <div class="progress-bar">
                        \(formatPriorityBar(high: highPriority, medium: mediumPriority, low: lowPriority, none: noPriority, total: totalPriorities))
                    </div>
                    <div class="stat-row">
                        <span>High priority:</span>
                        <span>\(highPriority)</span>
                    </div>
                    <div class="stat-row">
                        <span>Medium priority:</span>
                        <span>\(mediumPriority)</span>
                    </div>
                    <div class="stat-row">
                        <span>Low priority:</span>
                        <span>\(lowPriority)</span>
                    </div>
                    <div class="stat-row">
                        <span>No priority:</span>
                        <span>\(noPriority)</span>
                    </div>
                </div>
                
                <div class="stats-section">
                    <h2>Due Dates</h2>
                    <div class="stat-row">
                        <span>With due date:</span>
                        <span>\(withDueDate)</span>
                    </div>
                    <div class="stat-row">
                        <span>Overdue:</span>
                        <span>\(overdue)</span>
                    </div>
                    <div class="stat-row">
                        <span>Due within 7 days:</span>
                        <span>\(dueSoon)</span>
                    </div>
                </div>
                
                <div class="stats-section">
                    <h2>Tags</h2>
                    <div class="stat-row">
                        <span>With tags:</span>
                        <span>\(withTags)</span>
                    </div>
                    <div class="tag-cloud">
                        \(formatTagCloud(allTags))
                    </div>
                </div>
                
                <div class="stats-section">
                    <h2>Archive</h2>
                    <div class="stat-row">
                        <span>Completed:</span>
                        <span>\(completedCount)</span>
                    </div>
                    <div class="stat-row">
                        <span>Deleted:</span>
                        <span>\(deletedCount)</span>
                    </div>
                    <div class="stat-row">
                        <span>Expired:</span>
                        <span>\(expiredCount)</span>
                    </div>
                </div>
            </div>
        </body>
        </html>
        """
        
        return html
    }
    
    private static func formatPriorityBar(high: Int, medium: Int, low: Int, none: Int, total: Int) -> String {
        guard total > 0 else { return "" }
        
        let highPercent = high * 100 / total
        let mediumPercent = medium * 100 / total
        let lowPercent = low * 100 / total
        let nonePercent = 100 - highPercent - mediumPercent - lowPercent
        
        return """
            <div class="progress-segment progress-high" style="width: \(highPercent)%"></div>
            <div class="progress-segment progress-medium" style="width: \(mediumPercent)%"></div>
            <div class="progress-segment progress-low" style="width: \(lowPercent)%"></div>
            <div class="progress-segment progress-none" style="width: \(nonePercent)%"></div>
        """
    }
    
    private static func formatTagCloud(_ tags: [String: Int]) -> String {
        guard !tags.isEmpty else { return "" }
        
        return tags.sorted { $0.value > $1.value }
            .map { tag, count in
                """
                <span class="tag-stat">
                    #\(tag)
                    <span class="tag-count">\(count)</span>
                </span>
                """
            }
            .joined(separator: "\n")
    }
} 