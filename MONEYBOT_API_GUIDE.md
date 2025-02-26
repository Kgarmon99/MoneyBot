# MoneyBot API Guide

This document provides information on how to integrate your iOS app with the MoneyBot API service.

## API Base URL

When testing locally, your API base URL will be:
```
http://localhost:3000/api
```

When deploying to production, you'll need to replace this with your actual server URL.

## Available Endpoints

### 1. Health Check
```
GET /health
```
Response:
```json
{
  "status": "ok"
}
```

### 2. Get Available Models
```
GET /api/models
```
Response:
```json
{
  "data": [
    {
      "id": "gpt-4o",
      "name": "GPT-4o",
      "description": "Most advanced model, great for financial advice with stronger reasoning"
    },
    {
      "id": "gpt-4-turbo",
      "name": "GPT-4 Turbo",
      "description": "Enhanced version of GPT-4 with improved performance for financial analysis"
    },
    {
      "id": "gpt-3.5-turbo",
      "name": "GPT-3.5 Turbo",
      "description": "Fast and cost-effective model for basic financial queries and advice"
    }
  ]
}
```

### 3. Chat Completions
```
POST /api/chat/completions
```
Request Body:
```json
{
  "messages": [
    {
      "role": "user",
      "content": "Give me a quick tip about saving money"
    }
  ],
  "model": "gpt-3.5-turbo",
  "temperature": 0.7,
  "max_tokens": 500,
  "conversation_id": "optional-conversation-id"
}
```
Response: Standard OpenAI chat completion response with conversation tracking.

### 4. Financial Advice
```
POST /api/financial-advice
```
Request Body:
```json
{
  "topic": "investing",
  "question": "How can I start investing with a small amount of money?",
  "userContext": {
    "experience": "beginner",
    "age": 25,
    "hasDebt": false,
    "hasInvestments": false,
    "monthlyIncome": 4000
  }
}
```
Response:
```json
{
  "advice": "Detailed financial advice response...",
  "topic": "investing",
  "conversation_id": "123",
  "model": "gpt-4o"
}
```

## Implementing in Swift

### Basic API Client

```swift
import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

class MoneyBotAPI {
    private let baseURL = "http://localhost:3000/api"
    
    // Get available models
    func getModels() async throws -> [AIModel] {
        guard let url = URL(string: "\(baseURL)/models") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, 
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            let modelsResponse = try JSONDecoder().decode(ModelsResponse.self, from: data)
            return modelsResponse.data
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
    
    // Send chat completion request
    func sendChatCompletion(messages: [Message], model: String = "gpt-4o") async throws -> ChatCompletionResponse {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw APIError.invalidURL
        }
        
        let request = ChatCompletionRequest(messages: messages, model: model)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
    
    // Get financial advice
    func getFinancialAdvice(question: String, topic: String? = nil, userContext: UserContext? = nil) async throws -> FinancialAdviceResponse {
        guard let url = URL(string: "\(baseURL)/financial-advice") else {
            throw APIError.invalidURL
        }
        
        let request = FinancialAdviceRequest(topic: topic, question: question, userContext: userContext)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(FinancialAdviceResponse.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}

// Data models
struct ModelsResponse: Codable {
    let data: [AIModel]
}

struct AIModel: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
}

struct Message: Codable {
    let role: String // "system", "user", "assistant"
    let content: String
}

struct ChatCompletionRequest: Codable {
    let messages: [Message]
    let model: String
    let temperature: Double = 0.7
    let max_tokens: Int = 500
    let conversation_id: String? = nil
}

struct ChatCompletionResponse: Codable {
    let id: String
    let choices: [Choice]
    // Add other fields as needed
}

struct Choice: Codable {
    let message: Message
    let finish_reason: String
}

struct UserContext: Codable {
    let experience: String?
    let age: Int?
    let hasDebt: Bool?
    let hasInvestments: Bool?
    let monthlyIncome: Int?
}

struct FinancialAdviceRequest: Codable {
    let topic: String?
    let question: String
    let userContext: UserContext?
}

struct FinancialAdviceResponse: Codable {
    let advice: String
    let topic: String?
    let conversation_id: String
    let model: String
}
```

### Example Usage in SwiftUI

```swift
import SwiftUI

struct ChatView: View {
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var isLoading = false
    
    private let api = MoneyBotAPI()
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(0..<messages.count, id: \.self) { index in
                        MessageBubbleView(message: messages[index])
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Type a message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(inputText.isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle("MoneyBot")
    }
    
    func sendMessage() {
        let userMessage = Message(role: "user", content: inputText)
        messages.append(userMessage)
        
        let currentInput = inputText
        inputText = ""
        isLoading = true
        
        Task {
            do {
                let allMessages = messages
                let response = try await api.sendChatCompletion(messages: allMessages)
                
                DispatchQueue.main.async {
                    if let assistantMessage = response.choices.first?.message {
                        messages.append(assistantMessage)
                    }
                    isLoading = false
                }
            } catch {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
    }
}

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.role == "user" {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                Spacer()
            }
        }
    }
}
```

## Running the Server

To run the server locally:

```bash
node server-direct.js
```

This will start the server on port 3000, and you can connect your iOS app to it.