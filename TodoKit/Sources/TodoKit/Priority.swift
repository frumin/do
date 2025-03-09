import Foundation
import ArgumentParser

public enum Priority: String, Codable, ExpressibleByArgument {
    case high
    case medium
    case low
    case none
    
    public var rawValue: String {
        switch self {
        case .high: return "high"
        case .medium: return "medium"
        case .low: return "low"
        case .none: return "none"
        }
    }
    
    public var symbol: String {
        switch self {
        case .high: return "⚡"
        case .medium: return "●"
        case .low: return "○"
        case .none: return " "
        }
    }
    
    public init?(argument: String) {
        // Try numeric priority first
        if let number = Int(argument) {
            switch number {
            case 1: self = .high
            case 2: self = .medium
            case 3: self = .low
            case 4: self = .none
            default: return nil
            }
            return
        }
        
        // Fall back to string priority
        switch argument.lowercased() {
        case "high", "h": self = .high
        case "medium", "m": self = .medium
        case "low", "l": self = .low
        case "none", "n": self = .none
        default: return nil
        }
    }
    
    public var sortValue: Int {
        switch self {
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        case .none: return 4
        }
    }
} 