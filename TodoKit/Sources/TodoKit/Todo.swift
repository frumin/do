import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif
import ArgumentParser

public struct Todo: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var priority: Priority
    public var dueDate: Date?
    public var tags: [String]
    public let createdAt: Date
    public var completedAt: Date?
    
    public init(
        id: UUID = UUID(),
        title: String,
        priority: Priority = .none,
        dueDate: Date? = nil,
        tags: [String] = [],
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
        self.tags = tags
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
    
    public var formattedDueDate: String? {
        dueDate?.formatted(date: .numeric, time: .omitted)
    }
    
    public var formattedTags: String {
        tags.map { "#\($0)" }.joined(separator: " ")
    }
    
    public var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && completedAt == nil
    }
    
    #if canImport(SwiftUI)
    public var color: Color {
        priority.color
    }
    #endif
}

extension Todo {
    public func format(index: Int? = nil) -> String {
        var parts: [String] = []
        
        if let index = index {
            parts.append("\(index).")
        }
        
        parts.append(priority.symbol)
        parts.append(title)
        
        if let dueDate = formattedDueDate {
            parts.append("📅 \(dueDate)")
        }
        
        if !tags.isEmpty {
            parts.append(formattedTags)
        }
        
        return parts.joined(separator: " ")
    }
    
    public static func format(_ todos: [Todo], showNumbers: Bool = true) -> String {
        guard !todos.isEmpty else { return "No todos found" }
        
        return todos.enumerated().map { index, todo in
            todo.format(index: showNumbers ? index + 1 : nil)
        }.joined(separator: "\n")
    }
} 