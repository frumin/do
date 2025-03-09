import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif
import ArgumentParser

public struct Todo: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let priority: Priority
    public let dueDate: Date?
    public let tags: [String]
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        priority: Priority = .none,
        dueDate: Date? = nil,
        tags: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
        self.tags = tags
        self.createdAt = createdAt
    }
    
    public enum Priority: String, Codable, CaseIterable, ExpressibleByArgument {
        case high
        case medium
        case low
        case none
        
        public var symbol: String {
            switch self {
            case .high: return "⚡"
            case .medium: return "●"
            case .low: return "○"
            case .none: return " "
            }
        }
        
        #if canImport(SwiftUI)
        public var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .yellow
            case .low: return .green
            case .none: return .primary
            }
        }
        #endif
    }
}

extension Todo {
    public var isOverdue: Bool {
        guard let dueDate else { return false }
        return dueDate < Date()
    }
    
    public var formattedDueDate: String? {
        guard let dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: dueDate)
    }
    
    public var formattedTags: String {
        tags.map { "#\($0)" }.joined(separator: " ")
    }
    
    public func format(index: Int?) -> String {
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