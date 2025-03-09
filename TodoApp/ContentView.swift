import SwiftUI
import TodoKit

struct ContentView: View {
    @EnvironmentObject private var todoStore: TodoStore
    @State private var selectedFilter = Filter.all
    @State private var searchText = ""
    @State private var selectedTodoId: UUID?
    
    enum Filter: String {
        case all = "All"
        case today = "Today"
        case upcoming = "Upcoming"
        case overdue = "Overdue"
        case noDate = "No Date"
        case highPriority = "High Priority"
        case completed = "Completed"
        
        var icon: String {
            switch self {
            case .all: return "tray.fill"
            case .today: return "star.fill"
            case .upcoming: return "calendar"
            case .overdue: return "exclamationmark.circle.fill"
            case .noDate: return "calendar.badge.minus"
            case .highPriority: return "flag.fill"
            case .completed: return "checkmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return .gray
            case .today: return .orange
            case .upcoming: return .blue
            case .overdue: return .red
            case .noDate: return .gray
            case .highPriority: return .red
            case .completed: return .green
            }
        }
    }
    
    private var filteredTodos: [Todo] {
        let filtered = todoStore.todos.filter { todo in
            if !searchText.isEmpty {
                return todo.title.localizedCaseInsensitiveContains(searchText)
            }
            
            switch selectedFilter {
            case .all:
                return todo.completedAt == nil
            case .today:
                guard let dueDate = todo.dueDate else { return false }
                return Calendar.current.isDateInToday(dueDate) && todo.completedAt == nil
            case .upcoming:
                guard let dueDate = todo.dueDate else { return false }
                let inNext7Days = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
                return inNext7Days > 0 && inNext7Days <= 7 && todo.completedAt == nil
            case .overdue:
                return todo.isOverdue && todo.completedAt == nil
            case .noDate:
                return todo.dueDate == nil && todo.completedAt == nil
            case .highPriority:
                return todo.priority == .high && todo.completedAt == nil
            case .completed:
                return todo.completedAt != nil
            }
        }
        
        return filtered.sorted { a, b in
            if let aCompleted = a.completedAt, let bCompleted = b.completedAt {
                return aCompleted > bCompleted
            }
            if a.completedAt != nil { return false }
            if b.completedAt != nil { return true }
            
            if a.isOverdue && !b.isOverdue { return true }
            if !a.isOverdue && b.isOverdue { return false }
            
            if let aDate = a.dueDate, let bDate = b.dueDate {
                return aDate < bDate
            }
            
            return a.priority.sortValue < b.priority.sortValue
        }
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedFilter) {
                Section("Focus") {
                    ForEach([Filter.all, .today, .upcoming], id: \.self) { filter in
                        Label {
                            Text(filter.rawValue)
                        } icon: {
                            Image(systemName: filter.icon)
                                .foregroundStyle(filter.color)
                        }
                        .tag(filter)
                    }
                }
                
                Section("Filters") {
                    ForEach([Filter.overdue, .noDate, .highPriority], id: \.self) { filter in
                        Label {
                            Text(filter.rawValue)
                        } icon: {
                            Image(systemName: filter.icon)
                                .foregroundStyle(filter.color)
                        }
                        .tag(filter)
                    }
                }
                
                Section("Tags") {
                    ForEach(Array(todoStore.allTags).sorted(), id: \.self) { tag in
                        Label(tag, systemImage: "tag.fill")
                    }
                }
            }
            .navigationTitle("Todo")
        } detail: {
            List(selection: $selectedTodoId) {
                if todoStore.isLoading {
                    ProgressView()
                } else if let error = todoStore.error {
                    ErrorView(error: error)
                } else if filteredTodos.isEmpty {
                    EmptyStateView(filter: selectedFilter)
                } else {
                    ForEach(filteredTodos) { todo in
                        TodoRow(todo: todo)
                            .tag(todo.id)
                            .contextMenu {
                                Button {
                                    Task {
                                        await todoStore.completeTodo(todo)
                                    }
                                } label: {
                                    Label("Mark as Done", systemImage: "checkmark.circle")
                                }
                                
                                Button {
                                    todoStore.selectedTodo = todo
                                    todoStore.isShowingEditSheet = true
                                } label: {
                                    Label("Edit...", systemImage: "pencil")
                                }
                                
                                Divider()
                                
                                Button(role: .destructive) {
                                    Task {
                                        await todoStore.deleteTodo(todo)
                                    }
                                } label: {
                                    Label("Delete...", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .onChange(of: selectedTodoId) { id in
                todoStore.selectedTodo = filteredTodos.first { $0.id == id }
            }
            .navigationTitle(selectedFilter.rawValue)
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        Task {
                            await todoStore.loadTodos()
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    
                    Button {
                        todoStore.isShowingAddSheet = true
                    } label: {
                        Label("Add Todo", systemImage: "plus")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search todos...")
            .sheet(isPresented: $todoStore.isShowingAddSheet) {
                TodoEditor(mode: .add)
            }
            .sheet(isPresented: $todoStore.isShowingEditSheet) {
                if let todo = todoStore.selectedTodo {
                    TodoEditor(mode: .edit(todo))
                }
            }
        }
    }
}

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.red)
            
            Text("Error Loading Todos")
                .font(.headline)
            
            Text(error.localizedDescription)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct EmptyStateView: View {
    let filter: ContentView.Filter
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: filter.icon)
                .font(.system(size: 48))
                .foregroundStyle(filter.color)
            
            Text("No Todos")
                .font(.headline)
            
            Text(emptyStateMessage)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var emptyStateMessage: String {
        switch filter {
        case .all:
            return "Add your first todo to get started"
        case .today:
            return "No todos due today"
        case .upcoming:
            return "No upcoming todos in the next 7 days"
        case .overdue:
            return "No overdue todos - great job!"
        case .noDate:
            return "No todos without due dates"
        case .highPriority:
            return "No high priority todos"
        case .completed:
            return "No completed todos yet"
        }
    }
}

struct TodoRow: View {
    let todo: Todo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(todo.priority.symbol)
                    .foregroundStyle(todo.priority.color)
                
                Text(todo.title)
                    .fontWeight(.medium)
                    .strikethrough(todo.completedAt != nil)
                    .foregroundStyle(todo.completedAt != nil ? .secondary : .primary)
                
                Spacer()
                
                if let completedAt = todo.completedAt {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text(completedAt.formatted(date: .numeric, time: .shortened))
                            .font(.caption)
                    }
                    .foregroundStyle(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.green.opacity(0.1))
                    }
                } else if let dueDate = todo.formattedDueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(dueDate)
                            .font(.caption)
                    }
                    .foregroundStyle(todo.isOverdue ? .red : .blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(todo.isOverdue ? .red.opacity(0.1) : .blue.opacity(0.1))
                    }
                }
            }
            
            if !todo.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(todo.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background {
                                Capsule()
                                    .fill(.secondary.opacity(0.1))
                            }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
