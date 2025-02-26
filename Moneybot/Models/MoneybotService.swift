import Foundation
import Combine
import SwiftUI

class MoneybotService: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var suggestedFollowUps: [String] = []
    
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
        8. Provide age-appropriate financial advice
        9. For students and young adults, focus on building good financial habits, avoiding debt, and starting to save early
        10. For questions about investing, emphasize long-term thinking and risk management
        11. If asked about specific stocks or crypto, explain the risks without making specific investment recommendations
        12. End responses with a follow-up question to engage the user and encourage continued learning
        """)
        
        // Add welcome message
        addAssistantMessage("👋 Hi there! I'm Moneybot, your personal financial co-pilot. How can I help with your money questions today?")
        
        // Set initial suggested follow-ups
        updateSuggestedFollowUps()
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
        
        // Update suggested follow-ups based on the context
        updateSuggestedFollowUps()
    }
    
    private func updateSuggestedFollowUps() {
        // Get the last few messages to understand context
        let recentMessages = messages.filter { $0.role != .system }.suffix(3)
        let context = recentMessages.map { $0.content }.joined(separator: " ")
        
        // Dynamically generate follow-up questions based on the conversation
        if context.lowercased().contains("budget") {
            suggestedFollowUps = [
                "How do I create a simple budget?",
                "What's the 50/30/20 rule?",
                "How can I stick to my budget?"
            ]
        } else if context.lowercased().contains("invest") || context.lowercased().contains("stock") {
            suggestedFollowUps = [
                "What are index funds?",
                "How do I start investing with little money?",
                "What's the difference between stocks and bonds?"
            ]
        } else if context.lowercased().contains("debt") || context.lowercased().contains("loan") {
            suggestedFollowUps = [
                "How can I pay off debt faster?",
                "Which debts should I pay off first?",
                "What's a good debt-to-income ratio?"
            ]
        } else if context.lowercased().contains("save") || context.lowercased().contains("saving") {
            suggestedFollowUps = [
                "How much should I have in emergency savings?",
                "What are high-yield savings accounts?",
                "How can I automate my savings?"
            ]
        } else if context.lowercased().contains("credit") || context.lowercased().contains("score") {
            suggestedFollowUps = [
                "How can I improve my credit score?",
                "What factors affect my credit score?",
                "Should I close unused credit cards?"
            ]
        } else {
            suggestedFollowUps = [
                "How do I start saving money?",
                "What's an emergency fund?",
                "How should I invest my first $1,000?",
                "How can I improve my credit score?",
                "What's the 50/30/20 budget rule?"
            ]
        }
    }
    
    // Special functions for financial tasks
    func generateSavingsPlan(goal: Double, timeframe: Int) -> String {
        let monthlyAmount = goal / Double(timeframe)
        let weeklyAmount = monthlyAmount / 4.33
        
        return """
        🎯 **Savings Plan**
        
        Goal: $\(String(format: "%.2f", goal))
        Timeframe: \(timeframe) months
        
        Monthly savings needed: $\(String(format: "%.2f", monthlyAmount))
        Weekly savings needed: $\(String(format: "%.2f", weeklyAmount))
        
        Tip: Set up an automatic transfer to your savings account on payday to make saving easier!
        """
    }
    
    func calculateCompoundInterest(principal: Double, rate: Double, years: Int, monthlyContribution: Double = 0) -> String {
        let monthlyRate = rate / 100 / 12
        let totalMonths = years * 12
        
        var balance = principal
        for _ in 1...totalMonths {
            balance += monthlyContribution
            balance += balance * monthlyRate
        }
        
        let interest = balance - principal - (monthlyContribution * Double(totalMonths))
        
        return """
        📈 **Compound Interest Calculation**
        
        Initial investment: $\(String(format: "%.2f", principal))
        Monthly contribution: $\(String(format: "%.2f", monthlyContribution))
        Interest rate: \(String(format: "%.2f", rate))%
        Time period: \(years) years
        
        Final balance: $\(String(format: "%.2f", balance))
        Total interest earned: $\(String(format: "%.2f", interest))
        Total contribution: $\(String(format: "%.2f", principal + (monthlyContribution * Double(totalMonths))))
        
        The power of compound interest is amazing! 💰
        """
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
    
    // Helper method to detect if a message is asking about a specific financial calculation
    func processFinancialCalculations(message: String) -> Bool {
        // Check for compound interest calculation request
        if message.lowercased().contains("compound interest") && 
           message.lowercased().contains("calculate") {
            // Extract parameters (simplified implementation)
            let principal = 1000.0 // Default values
            let rate = 7.0
            let years = 10
            
            let response = calculateCompoundInterest(
                principal: principal,
                rate: rate,
                years: years
            )
            
            addAssistantMessage(response)
            return true
        }
        
        // Check for savings plan request
        if message.lowercased().contains("savings plan") || 
           (message.lowercased().contains("save") && message.lowercased().contains("goal")) {
            // Extract parameters (simplified implementation)
            let goal = 10000.0 // Default values
            let timeframe = 24
            
            let response = generateSavingsPlan(
                goal: goal,
                timeframe: timeframe
            )
            
            addAssistantMessage(response)
            return true
        }
        
        return false
    }
}
