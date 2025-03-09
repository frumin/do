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
                Button("Refresh") {
                    Task {
                        await todoStore.loadTodos()
                    }
                }
                .keyboardShortcut("r")
            }
        }
    }
}

@MainActor
class TodoStore: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let storage = TodoStorage.shared
    private var observationTask: Task<Void, Never>?
    
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
