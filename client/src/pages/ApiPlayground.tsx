import React, { useState } from 'react';
import { Link } from 'wouter';
import { queryClient } from '../lib/queryClient';
import { apiRequest } from '../lib/queryClient';

/**
 * API Playground Component - iOS Developer Focus
 */
const ApiPlayground = () => {
  const [endpoint, setEndpoint] = useState('/api/models');
  const [method, setMethod] = useState<'GET' | 'POST'>('GET');
  const [requestBody, setRequestBody] = useState('');
  const [response, setResponse] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  /**
   * Handle API request submission
   */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);

    try {
      const options: RequestInit = {
        method,
      };

      if (method === 'POST' && requestBody) {
        try {
          const parsedBody = JSON.parse(requestBody);
          options.body = JSON.stringify(parsedBody);
          options.headers = {
            'Content-Type': 'application/json',
          };
        } catch (e) {
          throw new Error('Invalid JSON in request body');
        }
      }

      const data = await apiRequest(endpoint, options);
      setResponse(data);
    } catch (err: any) {
      setError(err);
      console.error('API Request failed:', err);
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Format JSON for display
   */
  const formatJson = (json: any) => {
    return JSON.stringify(json, null, 2);
  };

  // Preset endpoints for quick testing
  const presetEndpoints = [
    { name: 'Get Models', endpoint: '/api/models', method: 'GET', body: '' },
    {
      name: 'Chat Completion',
      endpoint: '/api/chat/completions',
      method: 'POST',
      body: JSON.stringify({
        model: 'gpt-4o',
        messages: [
          { role: 'system', content: 'You are MoneyBot, an AI assistant specialized in finance.' },
          { role: 'user', content: 'How can I build an emergency fund?' }
        ]
      }, null, 2)
    },
    {
      name: 'Financial Advice',
      endpoint: '/api/financial-advice',
      method: 'POST',
      body: JSON.stringify({
        topic: 'saving',
        question: 'How do I save for retirement in my 30s?',
        userContext: {
          experience: 'intermediate',
          age: 35,
          hasDebt: true,
          hasInvestments: true,
          monthlyIncome: 5000
        }
      }, null, 2)
    }
  ];

  // Load preset endpoint data
  const handlePresetSelect = (preset: typeof presetEndpoints[0]) => {
    setEndpoint(preset.endpoint);
    setMethod(preset.method as 'GET' | 'POST');
    setRequestBody(preset.body);
  };

  return (
    <div className="container mx-auto px-4 py-8 max-w-6xl">
      <header className="mb-8">
        <div className="flex justify-between items-center">
          <h1 className="text-3xl font-bold text-green-700">MoneyBot API Playground</h1>
          <Link href="/">
            <a className="text-blue-600 hover:underline">Back to Home</a>
          </Link>
        </div>
        <p className="text-gray-600 dark:text-gray-300 mt-2">
          Test and explore the API endpoints for iOS integration
        </p>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Request Panel */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold mb-4 text-green-700">Make a Request</h2>
          
          <div className="mb-6">
            <h3 className="font-medium mb-2">Quick API Tests</h3>
            <div className="flex flex-wrap gap-2">
              {presetEndpoints.map((preset, idx) => (
                <button
                  key={idx}
                  onClick={() => handlePresetSelect(preset)}
                  className="px-3 py-1 bg-gray-200 dark:bg-gray-700 rounded-md text-sm hover:bg-gray-300 dark:hover:bg-gray-600"
                >
                  {preset.name}
                </button>
              ))}
            </div>
          </div>
          
          <form onSubmit={handleSubmit}>
            <div className="mb-4">
              <label className="block text-sm font-medium mb-1">Request Method</label>
              <div className="flex gap-4">
                <label className="inline-flex items-center">
                  <input
                    type="radio"
                    className="form-radio"
                    name="method"
                    value="GET"
                    checked={method === 'GET'}
                    onChange={() => setMethod('GET')}
                  />
                  <span className="ml-2">GET</span>
                </label>
                <label className="inline-flex items-center">
                  <input
                    type="radio"
                    className="form-radio"
                    name="method"
                    value="POST"
                    checked={method === 'POST'}
                    onChange={() => setMethod('POST')}
                  />
                  <span className="ml-2">POST</span>
                </label>
              </div>
            </div>
            
            <div className="mb-4">
              <label htmlFor="endpoint" className="block text-sm font-medium mb-1">
                Endpoint
              </label>
              <input
                id="endpoint"
                type="text"
                value={endpoint}
                onChange={(e) => setEndpoint(e.target.value)}
                className="w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
              />
            </div>
            
            {method === 'POST' && (
              <div className="mb-4">
                <label htmlFor="requestBody" className="block text-sm font-medium mb-1">
                  Request Body (JSON)
                </label>
                <textarea
                  id="requestBody"
                  value={requestBody}
                  onChange={(e) => setRequestBody(e.target.value)}
                  rows={10}
                  className="w-full border rounded-md px-3 py-2 font-mono text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
            )}
            
            <button
              type="submit"
              disabled={isLoading}
              className="w-full bg-green-600 text-white rounded-md px-4 py-2 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 disabled:opacity-50"
            >
              {isLoading ? 'Sending...' : 'Send Request'}
            </button>
          </form>
        </div>

        {/* Response Panel */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold mb-4 text-green-700">Response</h2>
          
          {isLoading ? (
            <div className="h-64 flex items-center justify-center">
              <div className="text-center">
                <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-green-500 mx-auto"></div>
                <p className="mt-3 text-gray-500">Loading...</p>
              </div>
            </div>
          ) : error ? (
            <div className="border border-red-300 bg-red-50 dark:bg-red-900/20 rounded-md p-4">
              <h3 className="text-red-800 dark:text-red-300 font-medium mb-2">Error</h3>
              <pre className="whitespace-pre-wrap text-red-600 dark:text-red-400 text-sm">
                {error.message}
              </pre>
            </div>
          ) : response ? (
            <div className="border rounded-md p-4 h-96 overflow-auto">
              <pre className="whitespace-pre-wrap text-sm font-mono">
                {formatJson(response)}
              </pre>
            </div>
          ) : (
            <div className="h-64 flex items-center justify-center text-gray-500">
              <p>Send a request to see the response</p>
            </div>
          )}
        </div>
      </div>

      {/* iOS Integration Examples */}
      <div className="mt-12 bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
        <h2 className="text-xl font-semibold mb-6 text-green-700">iOS Integration Examples</h2>
        
        <div className="mb-8">
          <h3 className="font-semibold mb-3 text-lg">Swift API Client Example</h3>
          <div className="bg-gray-100 dark:bg-gray-900 rounded-md p-4 overflow-auto">
            <pre className="whitespace-pre-wrap text-sm font-mono">
{`import Foundation

class MoneyBotService {
    private let baseURL = "https://your-moneybot-api.com/api"
    private var apiKey: String?
    
    init(apiKey: String? = nil) {
        self.apiKey = apiKey
    }
    
    // MARK: - Chat API
    
    func sendChatMessage(message: String, model: String = "gpt-4o", 
                         conversationId: String? = nil,
                         completion: @escaping (Result<ChatResponse, Error>) -> Void) {
        
        let endpoint = "\(baseURL)/chat/completions"
        
        // Setup the message request
        let systemPrompt = "You are MoneyBot, an advanced AI assistant specializing in financial advice."
        let messageRequest = ChatRequest(
            model: model,
            messages: [
                Message(role: "system", content: systemPrompt),
                Message(role: "user", content: message)
            ],
            conversation_id: conversationId
        )
        
        // Make the request
        makeRequest(to: endpoint,
                    method: "POST",
                    body: messageRequest,
                    completion: completion)
    }
    
    // MARK: - Financial Advice API
    
    func getFinancialAdvice(topic: String? = nil,
                           question: String,
                           experience: String? = nil,
                           age: Int? = nil,
                           hasDebt: Bool? = nil,
                           hasInvestments: Bool? = nil,
                           monthlyIncome: Double? = nil,
                           completion: @escaping (Result<FinancialAdviceResponse, Error>) -> Void) {
        
        let endpoint = "\(baseURL)/financial-advice"
        
        // Setup user context if provided
        var userContext: UserContext? = nil
        if experience != nil || age != nil || hasDebt != nil || hasInvestments != nil || monthlyIncome != nil {
            userContext = UserContext(
                experience: experience,
                age: age,
                hasDebt: hasDebt,
                hasInvestments: hasInvestments,
                monthlyIncome: monthlyIncome
            )
        }
        
        // Create the request
        let request = FinancialAdviceRequest(
            topic: topic,
            question: question,
            userContext: userContext
        )
        
        // Make the request
        makeRequest(to: endpoint,
                    method: "POST",
                    body: request,
                    completion: completion)
    }
    
    // MARK: - Generic Request Helper
    
    private func makeRequest<T: Encodable, R: Decodable>(to endpoint: String,
                                                         method: String,
                                                         body: T? = nil,
                                                         completion: @escaping (Result<R, Error>) -> Void) {
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "MoneyBotService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let apiKey = apiKey {
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "MoneyBotService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(R.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Data Models

struct Message: Codable {
    let role: String
    let content: String
}

struct ChatRequest: Codable {
    let model: String
    let messages: [Message]
    let conversation_id: String?
    let temperature: Double?
    let max_tokens: Int?
    
    init(model: String, messages: [Message], conversation_id: String? = nil, temperature: Double? = 0.7, max_tokens: Int? = 500) {
        self.model = model
        self.messages = messages
        self.conversation_id = conversation_id
        self.temperature = temperature
        self.max_tokens = max_tokens
    }
}

struct ChatChoice: Codable {
    let message: Message
    let finish_reason: String
    let index: Int
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

struct ChatResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [ChatChoice]
    let usage: Usage
    let conversation_id: String?
}

struct UserContext: Codable {
    let experience: String?
    let age: Int?
    let hasDebt: Bool?
    let hasInvestments: Bool?
    let monthlyIncome: Double?
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
}`}
            </pre>
          </div>
        </div>
        
        <div className="mb-8">
          <h3 className="font-semibold mb-3 text-lg">SwiftUI Example Usage</h3>
          <div className="bg-gray-100 dark:bg-gray-900 rounded-md p-4 overflow-auto">
            <pre className="whitespace-pre-wrap text-sm font-mono">
{`import SwiftUI

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    
    private let moneyBotService = MoneyBotService()
    @State private var conversationId: String?
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Ask MoneyBot...", text: $messageText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .disabled(isLoading)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .disabled(messageText.isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle("MoneyBot")
    }
    
    private func sendMessage() {
        let userMessage = messageText
        
        // Add user message to chat
        let userChatMessage = ChatMessage(id: UUID().uuidString, role: .user, content: userMessage)
        messages.append(userChatMessage)
        
        // Clear message field
        messageText = ""
        isLoading = true
        
        // Call API
        moneyBotService.sendChatMessage(message: userMessage, conversationId: conversationId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    // Save conversation ID for future messages
                    self.conversationId = response.conversation_id
                    
                    // Add bot response to chat
                    if let botMessage = response.choices.first?.message {
                        let botChatMessage = ChatMessage(
                            id: UUID().uuidString,
                            role: .assistant,
                            content: botMessage.content
                        )
                        self.messages.append(botChatMessage)
                    }
                    
                case .failure(let error):
                    // Handle error
                    print("Error: \(error.localizedDescription)")
                    let errorMessage = ChatMessage(
                        id: UUID().uuidString,
                        role: .assistant,
                        content: "Sorry, I had trouble responding. Please try again."
                    )
                    self.messages.append(errorMessage)
                }
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id: String
    let role: MessageRole
    let content: String
}

enum MessageRole {
    case user
    case assistant
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading) {
                Text(message.content)
                    .padding(12)
                    .background(message.role == .user ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .cornerRadius(16)
                    .cornerRadius(16, corners: message.role == .user ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
            }
            .frame(maxWidth: 280, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}`}
            </pre>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ApiPlayground;