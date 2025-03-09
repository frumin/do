import Foundation

struct HTMLFormatter {
    static func format(_ todos: [TodoItem]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Todo List</title>
            <style>
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
                h1 {
                    color: #212529;
                    margin-bottom: 1.5rem;
                }
            </style>
        </head>
        <body>
            <h1>Todo List</h1>
            <div class="todo-list">
        """
        
        let todoItems = todos.enumerated().map { (index, todo) -> String in
            let priorityClass = switch todo.priority {
                case .high: "priority-high"
                case .medium: "priority-medium"
                case .low: "priority-low"
                case .none: ""
            }
            
            let prioritySymbol = todo.priority.symbol
            
            var dueDateHtml = ""
            if let dueDate = todo.dueDate {
                let isOverdue = todo.isOverdue
                dueDateHtml = """
                    <span class="due-date\(isOverdue ? " overdue" : "")">
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
                </div>
            """
        }.joined(separator: "\n")
        
        return html + todoItems + """
            </div>
        </body>
        </html>
        """
    }
} 