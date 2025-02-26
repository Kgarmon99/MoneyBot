import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: UUID = UUID()
    let role: MessageRole
    let content: String
    let timestamp: Date = Date()
}

// OpenAI API request and response models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    
    struct OpenAIMessage: Codable {
        let role: String
        let content: String
    }
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        
        let message: Message
        let finishReason: String
        
        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }
    
    let choices: [Choice]
}
