import Foundation

enum MessageRole: String, Codable {
    case system
    case user
    case assistant
    
    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .user:
            return "You"
        case .assistant:
            return "Moneybot"
        }
    }
}
