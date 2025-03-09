import SwiftUI
import TodoKit

struct ContentView: View {
    @EnvironmentObject private var todoStore: TodoStore
    @State private var selectedPriority: Todo.Priority?
    @State private var searchText = ""
    @State private var showOverdueOnly = false
    
    private var filteredTodos: [Todo] {
        todoStore.todos.filter { todo in
            let matchesPriority = selectedPriority == nil || todo.priority == selectedPriority
            let matchesSearch = searchText.isEmpty || todo.title.localizedCaseInsensitiveContains(searchText)
            let matchesOverdue = !showOverdueOnly || todo.isOverdue
            return matchesPriority && matchesSearch && matchesOverdue
        }
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedPriority) {
                Text("All")
                    .tag(nil as Todo.Priority?)
                
                Section("Priorities") {
                    ForEach([Todo.Priority.high, .medium, .low, .none], id: \.self) { priority in
                        Label {
                            Text(priority.rawValue.capitalized)
                        } icon: {
                            Text(priority.symbol)
                        }
                        .tag(priority as Todo.Priority?)
                    }
                }
            }
        } detail: {
            List {
                if todoStore.isLoading {
                    ProgressView()
                } else if let error = todoStore.error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundStyle(.red)
                } else if filteredTodos.isEmpty {
                    Text("No todos found")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredTodos) { todo in
                        TodoRow(todo: todo)
                    }
                }
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        Task {
                            await todoStore.loadTodos()
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    
                    Toggle(isOn: $showOverdueOnly) {
                        Label("Show Overdue Only", systemImage: "exclamationmark.circle")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search todos...")
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
                
                if let dueDate = todo.formattedDueDate {
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                        Text(dueDate)
                    }
                    .foregroundStyle(todo.isOverdue ? .red : .blue)
                }
            }
            
            if !todo.tags.isEmpty {
                Text(todo.formattedTags)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
