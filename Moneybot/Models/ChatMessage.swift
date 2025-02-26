import Foundation

/**
 * ChatMessage - Represents a single message in the chat
 */
struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    let content: String
    let timestamp = Date()
}
