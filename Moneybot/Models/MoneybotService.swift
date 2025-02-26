import Foundation
import Combine

class MoneybotService: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    
    private let openAIURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Add initial system message
        let systemMessage = ChatMessage(
            role: .system,
            content: "You are Moneybot, a friendly and helpful financial advisor. Your goal is to help users understand financial concepts, make better financial decisions, and achieve their financial goals. Use simple language, be encouraging, and always prioritize the user's financial well-being."
        )
        messages.append(systemMessage)
        
        // Add welcome message
        let welcomeMessage = ChatMessage(
            role: .assistant,
            content: "Hi there! I'm Moneybot, your personal financial co-pilot. 💰 I'm here to help you with budgeting, saving, investing, or any other money questions you might have. What would you like to talk about today?"
        )
        messages.append(welcomeMessage)
    }
    
    func sendMessage(_ content: String) {
        let userMessage = ChatMessage(role: .user, content: content)
        messages.append(userMessage)
        
        requestChatCompletion()
    }
    
    private func requestChatCompletion() {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            let errorMessage = ChatMessage(
                role: .assistant,
                content: "I'm having trouble connecting to my brain right now. Please check your OpenAI API key configuration."
            )
            messages.append(errorMessage)
            return
        }
        
        isLoading = true
        
        // Convert messages for API format
        let apiMessages = messages.map { OpenAIChatRequest.OpenAIChatMessage(role: $0.role.rawValue, content: $0.content) }
        
        let request = OpenAIChatRequest(
            model: "gpt-3.5-turbo",
            messages: apiMessages,
            temperature: 0.7
        )
        
        var urlRequest = URLRequest(url: openAIURL)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            handleError(error)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: OpenAIChatResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self, let content = response.choices.first?.message.content else { return }
                    
                    let responseMessage = ChatMessage(
                        role: .assistant,
                        content: content
                    )
                    self.messages.append(responseMessage)
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        print("OpenAI API Error: \(error)")
        let errorMessage = ChatMessage(
            role: .assistant,
            content: "I'm having trouble right now. Please try again later."
        )
        messages.append(errorMessage)
    }
}
