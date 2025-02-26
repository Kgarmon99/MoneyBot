import Foundation
import SwiftUI

/**
 * MoneybotService - Handles communication with OpenAI API for financial advice
 */
class MoneybotService: ObservableObject {
    // Published properties to support SwiftUI views
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    
    // Static instance for singleton access
    static let shared = MoneybotService()
    
    // System prompts to define the personality and capabilities of Moneybot
    private let systemPrompts = [
        "You are Moneybot, a helpful financial co-pilot designed to provide personalized financial advice.",
        "You analyze expenses, help create budgets, explain financial concepts, and provide guidance on investing.",
        "You are friendly, encouraging, and make finance simple to understand.",
        "Tailor advice to the user's experience level and financial situation.",
        "Focus on practical advice that can be implemented immediately.",
        "If you don't know the answer, be honest and suggest resources to learn more.",
        "Never recommend specific stocks or make promises about investment returns.",
        "Your goal is to help users build better money habits through education and planning."
    ]
    
    // Private constructor for singleton pattern
    private init() {
        // Initialize the chat with a welcome message
        let welcomeMessage = ChatMessage(
            role: .assistant,
            content: "Hi there! I'm Moneybot, your financial co-pilot. I can help you with budgeting, saving, investing, or understanding financial concepts. What's on your financial mind today?"
        )
        messages.append(welcomeMessage)
    }
    
    /**
     * Sends a message to the OpenAI API and gets a response
     * @param userMessage The message from the user
     * @param completion Callback with the result
     */
    func sendMessage(_ userMessage: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Add user message to chat history
        let userChatMessage = ChatMessage(role: .user, content: userMessage)
        messages.append(userChatMessage)
        
        // Start loading state
        isLoading = true
        
        // Construct messages for API call
        var apiMessages: [[String: Any]] = []
        
        // Add system prompt first
        apiMessages.append([
            "role": "system",
            "content": systemPrompts.joined(separator: " ")
        ])
        
        // Add conversation history (limited to last 10 messages to stay within token limits)
        let recentMessages = messages.suffix(10)
        for message in recentMessages {
            apiMessages.append([
                "role": message.role.rawValue,
                "content": message.content
            ])
        }
        
        // Prepare the request body
        let requestBody: [String: Any] = [
            "model": "gpt-4o",  // Using the latest model
            "messages": apiMessages,
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        // Convert request body to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            isLoading = false
            completion(.failure(NSError(domain: "MoneybotService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create request data"])))
            return
        }
        
        // Create the URL request
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            isLoading = false
            completion(.failure(NSError(domain: "MoneybotService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the API key from environment or info.plist
        // In a real app, you'd store this securely using Keychain
        // Replace "YOUR_OPENAI_API_KEY" with your actual OpenAI API key when testing the app
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "YOUR_OPENAI_API_KEY"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = jsonData
        
        // Make the API call
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                // Handle errors
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Check for data
                guard let data = data else {
                    completion(.failure(NSError(domain: "MoneybotService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                // Parse the response
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        
                        // Add assistant message to chat history
                        let assistantMessage = ChatMessage(role: .assistant, content: content)
                        self?.messages.append(assistantMessage)
                        
                        // Return success
                        completion(.success(content))
                    } else {
                        // Try to extract error message
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = json["error"] as? [String: Any],
                           let message = error["message"] as? String {
                            completion(.failure(NSError(domain: "MoneybotService", code: 4, userInfo: [NSLocalizedDescriptionKey: message])))
                        } else {
                            completion(.failure(NSError(domain: "MoneybotService", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    /**
     * Clears the chat history
     */
    func clearChat() {
        messages = []
        let welcomeMessage = ChatMessage(
            role: .assistant,
            content: "Hi there! I'm Moneybot, your financial co-pilot. I can help you with budgeting, saving, investing, or understanding financial concepts. What's on your financial mind today?"
        )
        messages.append(welcomeMessage)
    }
}
