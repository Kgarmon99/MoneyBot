import Foundation

struct ChatMessage: Identifiable, Codable {
    var id: UUID = UUID()
    var role: MessageRole
    var content: String
    var timestamp: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id, role, content, timestamp
    }
}

// Request and response structures for OpenAI API
struct OpenAIChatRequest: Codable {
    var model: String
    var messages: [OpenAIChatMessage]
    var temperature: Float
    
    struct OpenAIChatMessage: Codable {
        var role: String
        var content: String
    }
}

struct OpenAIChatResponse: Codable {
    var id: String
    var object: String
    var created: TimeInterval
    var model: String
    var choices: [Choice]
    
    struct Choice: Codable {
        var index: Int
        var message: Message
        var finishReason: String
        
        enum CodingKeys: String, CodingKey {
            case index, message
            case finishReason = "finish_reason"
        }
    }
    
    struct Message: Codable {
        var role: String
        var content: String
    }
}
