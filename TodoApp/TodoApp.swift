import SwiftUI
import TodoKit

@main
struct TodoApp: App {
    @StateObject private var todoStore = TodoStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(todoStore)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Todo") {
                    todoStore.isShowingAddSheet = true
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("Refresh") {
                    Task {
                        await todoStore.loadTodos()
                    }
                }
                .keyboardShortcut("r", modifiers: .command)
            }
            
            CommandMenu("Todo") {
                Button("Mark as Done") {
                    if let todo = todoStore.selectedTodo {
                        Task {
                            await todoStore.completeTodo(todo)
                        }
                    }
                }
                .keyboardShortcut("d", modifiers: .command)
                .disabled(todoStore.selectedTodo == nil)
                
                Button("Edit...") {
                    if todoStore.selectedTodo != nil {
                        todoStore.isShowingEditSheet = true
                    }
                }
                .keyboardShortcut("e", modifiers: .command)
                .disabled(todoStore.selectedTodo == nil)
                
                Divider()
                
                Button("Delete...") {
                    if let todo = todoStore.selectedTodo {
                        Task {
                            await todoStore.deleteTodo(todo)
                        }
                    }
                }
                .keyboardShortcut(.delete, modifiers: .command)
                .disabled(todoStore.selectedTodo == nil)
            }
        }
    }
}

@MainActor
class TodoStore: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedTodo: Todo?
    @Published var isShowingAddSheet = false
    @Published var isShowingEditSheet = false
    
    private let storage = TodoStorage.shared
    private var observationTask: Task<Void, Never>?
    
    var allTags: Set<String> {
        Set(todos.flatMap(\.tags))
    }
    
    init() {
        print("TodoStore initialized")
        Task {
            await loadTodos()
            await startObserving()
        }
    }
    
    deinit {
        observationTask?.cancel()
    }
    
    func loadTodos() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            todos = try await storage.readTodos()
            print("Successfully loaded \(todos.count) todos")
            if let firstTodo = todos.first {
                print("Sample todo: \(firstTodo.title)")
            }
        } catch {
            print("Error loading todos: \(error)")
            self.error = error
        }
    }
    
    func addTodo(_ todo: Todo) async {
        do {
            try await storage.addTodo(todo)
            await loadTodos()
        } catch {
            self.error = error
        }
    }
    
    func updateTodo(_ todo: Todo) async {
        do {
            try await storage.updateTodo(todo)
            await loadTodos()
        } catch {
            self.error = error
        }
    }
    
    func deleteTodo(_ todo: Todo) async {
        do {
            try await storage.deleteTodo(todo)
            await loadTodos()
        } catch {
            self.error = error
        }
    }
    
    func completeTodo(_ todo: Todo) async {
        var updatedTodo = todo
        updatedTodo.completedAt = Date()
        await updateTodo(updatedTodo)
    }
    
    private func startObserving() async {
        observationTask = Task {
            for await todos in await storage.observeChanges() {
                await MainActor.run {
                    self.todos = todos
                }
            }
        }
    }
}
