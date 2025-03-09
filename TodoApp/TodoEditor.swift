import SwiftUI
import TodoKit

struct TodoEditor: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var todoStore: TodoStore
    @FocusState private var focusedField: Field?
    
    let mode: Mode
    @State private var title: String
    @State private var priority: Priority
    @State private var dueDate: Date?
    @State private var tags: [String]
    @State private var isShowingDatePicker = false
    @State private var isShowingPriorityPicker = false
    
    private enum Field {
        case title
        case tags
    }
    
    enum Mode {
        case add
        case edit(Todo)
        
        var title: String {
            switch self {
            case .add: return "New Todo"
            case .edit: return "Edit Todo"
            }
        }
    }
    
    init(mode: Mode) {
        self.mode = mode
        
        switch mode {
        case .add:
            _title = State(initialValue: "")
            _priority = State(initialValue: .none)
            _dueDate = State(initialValue: nil)
            _tags = State(initialValue: [])
        case .edit(let todo):
            _title = State(initialValue: todo.title)
            _priority = State(initialValue: todo.priority)
            _dueDate = State(initialValue: todo.dueDate)
            _tags = State(initialValue: todo.tags)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                titleSection
                detailsSection
                tagsSection
            }
            .navigationTitle(mode.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    let title: String = {
                        switch mode {
                        case .add: return "Add"
                        case .edit: return "Save"
                        }
                    }()
                    
                    Button(title) {
                        Task {
                            switch mode {
                            case .add:
                                let todo = Todo(
                                    title: title,
                                    priority: priority,
                                    dueDate: dueDate,
                                    tags: tags
                                )
                                await todoStore.addTodo(todo)
                            case .edit(let todo):
                                var updatedTodo = todo
                                updatedTodo.title = title
                                updatedTodo.priority = priority
                                updatedTodo.dueDate = dueDate
                                updatedTodo.tags = tags
                                await todoStore.updateTodo(updatedTodo)
                            }
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            focusedField = .title
        }
    }
    
    private var titleSection: some View {
        Section {
            TextField("Title", text: $title)
                .font(.body)
                .textFieldStyle(.plain)
                .focused($focusedField, equals: .title)
        }
    }
    
    private var detailsSection: some View {
        Section {
            priorityButton
            if isShowingPriorityPicker {
                priorityPicker
            }
            
            dueDateButton
            if isShowingDatePicker {
                dueDatePicker
            }
        }
    }
    
    private var priorityButton: some View {
        Button {
            isShowingPriorityPicker.toggle()
        } label: {
            HStack {
                Label {
                    Text("Priority")
                } icon: {
                    Image(systemName: priority.symbol)
                        .foregroundStyle(priority.color)
                }
                
                Spacer()
                
                Text(priority.rawValue)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var priorityPicker: some View {
        Picker("Priority", selection: $priority) {
            ForEach([Priority.none, .low, .medium, .high], id: \.self) { priority in
                Label {
                    Text(priority.rawValue)
                } icon: {
                    Image(systemName: priority.symbol)
                        .foregroundStyle(priority.color)
                }
                .tag(priority)
            }
        }
        .pickerStyle(.inline)
        .listRowSeparator(.hidden)
    }
    
    private var dueDateButton: some View {
        Button {
            isShowingDatePicker.toggle()
            if isShowingDatePicker && dueDate == nil {
                dueDate = Calendar.current.startOfDay(for: Date())
            }
        } label: {
            HStack {
                Label {
                    Text("Due Date")
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundStyle(.blue)
                }
                
                Spacer()
                
                if let dueDate {
                    Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.secondary)
                } else {
                    Text("None")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private var dueDatePicker: some View {
        VStack(spacing: 0) {
            DatePicker(
                "Due Date",
                selection: Binding(
                    get: { dueDate ?? Date() },
                    set: { dueDate = Calendar.current.startOfDay(for: $0) }
                ),
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .listRowSeparator(.hidden)
            
            Button(role: .destructive) {
                dueDate = nil
                isShowingDatePicker = false
            } label: {
                Text("Clear Due Date")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .listRowInsets(EdgeInsets())
    }
    
    private var tagsSection: some View {
        Section {
            TextField("Add tags...", text: .init(
                get: { tags.joined(separator: ", ") },
                set: { tags = $0.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty } }
            ))
            .focused($focusedField, equals: .tags)
            .autocorrectionDisabled()
            
            if !todoStore.allTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(todoStore.allTags).sorted(), id: \.self) { tag in
                            tagButton(tag)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowSeparator(.hidden)
            }
        } header: {
            Text("Tags")
        } footer: {
            Text("Separate multiple tags with commas")
                .foregroundStyle(.secondary)
        }
    }
    
    private func tagButton(_ tag: String) -> some View {
        Button {
            if tags.contains(tag) {
                tags.removeAll { $0 == tag }
            } else {
                tags.append(tag)
            }
        } label: {
            Text(tag)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .fill(tags.contains(tag) ? .blue : .secondary.opacity(0.1))
                }
                .foregroundStyle(tags.contains(tag) ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
} 