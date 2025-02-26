import Foundation
import Combine
import SwiftUI

class MoneybotService: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Add initial system message - not visible to the user
        addSystemMessage("""
        You are Moneybot, a friendly and knowledgeable financial advisor assistant. Your purpose is to help users understand financial concepts, make better financial decisions, and achieve their money goals.
        
        Guidelines:
        1. Keep answers concise and simple - use everyday language anyone can understand
        2. Be encouraging, positive, and non-judgmental
        3. Focus on practical advice rather than technical details
        4. Provide actionable steps when possible
        5. Always prioritize the user's financial well-being
        6. When relevant, explain financial concepts clearly
        7. Use emoji occasionally to keep the conversation friendly 💰
        """)
        
        // Add welcome message
        addAssistantMessage("👋 Hi there! I'm Moneybot, your personal financial co-pilot. How can I help with your money questions today?")
    }
    
    func sendMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(role: .user, content: content)
        messages.append(userMessage)
        
        requestOpenAIResponse()
    }
    
    private func addSystemMessage(_ content: String) {
        let message = ChatMessage(role: .system, content: content)
        messages.append(message)
    }
    
    private func addAssistantMessage(_ content: String) {
        let message = ChatMessage(role: .assistant, content: content)
        messages.append(message)
    }
    
    private func requestOpenAIResponse() {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            addAssistantMessage("Sorry, I'm having trouble connecting to my brain. Please make sure you have set up your OpenAI API key correctly.")
            return
        }
        
        isLoading = true
        
        // Prepare messages for API
        let apiMessages = messages.map { OpenAIRequest.OpenAIMessage(role: $0.role.rawValue, content: $0.content) }
        
        let request = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: apiMessages,
            temperature: 0.7
        )
        
        // Create URL request
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            handleError("Invalid API URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            handleError("Failed to encode request: \(error.localizedDescription)")
            return
        }
        
        // Make API call
        URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: OpenAIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.handleError("API Error: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] response in
                    guard 
                        let self = self,
                        let choice = response.choices.first,
                        !choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    else {
                        self?.handleError("Received empty response")
                        return
                    }
                    
                    self.addAssistantMessage(choice.message.content)
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleError(_ message: String) {
        print("Moneybot Error: \(message)")
        isLoading = false
        addAssistantMessage("Sorry, I'm having some technical difficulties right now. Please try again in a moment.")
    }
}
