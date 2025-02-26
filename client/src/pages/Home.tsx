import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { AlertTriangle } from "lucide-react";
import EndpointCard from "@/components/EndpointCard";
import CodeBlock from "@/components/CodeBlock";

const Home = () => {
  return (
    <div className="p-4 lg:p-8 max-w-4xl mx-auto">
      {/* Header */}
      <header className="mb-8 border-b border-[#E5E5E5] pb-6">
        <h1 className="text-2xl lg:text-3xl font-bold mb-2">MoneyBot API Reference</h1>
        <p className="text-[#6E6E80] text-lg mb-4">
          The RESTful API for integrating ChatGPT functionality with mobile applications.
        </p>
        <div className="flex flex-wrap gap-2">
          <Badge variant="outline" className="bg-[#F7F7F8] text-[#6E6E80]">Version 1.0.0</Badge>
          <Badge variant="outline" className="bg-[#F7F7F8] text-[#6E6E80]">iOS Compatible</Badge>
        </div>
      </header>
      
      {/* Overview Section */}
      <section id="overview" className="mb-10">
        <h2 className="text-xl font-bold mb-4">Overview</h2>
        <p className="mb-4">
          The MoneyBot API provides a bridge between your applications and ChatGPT functionality. 
          It's designed specifically for iOS integration with the MoneyBot iOS app but can be used with any client.
        </p>
        <Card className="bg-[#F7F7F8] mb-6">
          <CardContent className="p-4">
            <h3 className="font-medium mb-2">Base URL</h3>
            <CodeBlock code="https://api.moneybot.io/v1" />
          </CardContent>
        </Card>
        <Card className="bg-[#F7F7F8]">
          <CardContent className="p-4">
            <h3 className="font-medium mb-2">Request Format</h3>
            <p className="mb-2 text-sm">All requests should be sent as JSON with the appropriate content-type header:</p>
            <CodeBlock code="Content-Type: application/json" />
          </CardContent>
        </Card>
      </section>
      
      {/* Authentication Section */}
      <section id="authentication" className="mb-10">
        <h2 className="text-xl font-bold mb-4">Authentication</h2>
        <p className="mb-4">
          All API requests require authentication using an API key. Your API key should be included in the
          header of each request.
        </p>
        <Card className="bg-[#F7F7F8]">
          <CardContent className="p-4">
            <h3 className="font-medium mb-3">API Key Authentication</h3>
            <p className="mb-2 text-sm">Include your API key in the request header:</p>
            <CodeBlock code="Authorization: Bearer YOUR_API_KEY" />
            <div className="bg-yellow-50 border-l-4 border-yellow-400 p-3 mt-4 rounded-r">
              <h4 className="font-medium text-sm">Important</h4>
              <p className="text-sm">Keep your API key secure and never expose it in client-side code. For iOS apps, 
              store the key securely using Keychain Services.</p>
            </div>
          </CardContent>
        </Card>
      </section>
      
      {/* Errors Section */}
      <section id="errors" className="mb-10">
        <h2 className="text-xl font-bold mb-4">Errors</h2>
        <p className="mb-4">
          The API uses conventional HTTP response codes to indicate the success or failure of an API request.
        </p>
        <div className="overflow-x-auto mb-4">
          <table className="min-w-full border border-[#E5E5E5]">
            <thead className="bg-[#F7F7F8]">
              <tr>
                <th className="py-2 px-4 border-b text-left">Code</th>
                <th className="py-2 px-4 border-b text-left">Description</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td className="py-2 px-4 border-b font-mono">200 - OK</td>
                <td className="py-2 px-4 border-b">The request was successful.</td>
              </tr>
              <tr>
                <td className="py-2 px-4 border-b font-mono">400 - Bad Request</td>
                <td className="py-2 px-4 border-b">The request was invalid or cannot be served.</td>
              </tr>
              <tr>
                <td className="py-2 px-4 border-b font-mono">401 - Unauthorized</td>
                <td className="py-2 px-4 border-b">Authentication failed or user doesn't have permissions.</td>
              </tr>
              <tr>
                <td className="py-2 px-4 border-b font-mono">403 - Forbidden</td>
                <td className="py-2 px-4 border-b">The request is understood but refused due to permissions.</td>
              </tr>
              <tr>
                <td className="py-2 px-4 border-b font-mono">404 - Not Found</td>
                <td className="py-2 px-4 border-b">The requested resource could not be found.</td>
              </tr>
              <tr>
                <td className="py-2 px-4 border-b font-mono">429 - Too Many Requests</td>
                <td className="py-2 px-4 border-b">The user has sent too many requests in a given amount of time.</td>
              </tr>
              <tr>
                <td className="py-2 px-4 font-mono">500 - Server Error</td>
                <td className="py-2 px-4">An error occurred on the server.</td>
              </tr>
            </tbody>
          </table>
        </div>
        <Card className="bg-[#F7F7F8]">
          <CardContent className="p-4">
            <h3 className="font-medium mb-3">Error Response Format</h3>
            <p className="mb-2 text-sm">Error responses include a JSON object with error details:</p>
            <CodeBlock 
              code={`{
  "error": {
    "code": "authentication_error",
    "message": "API key is invalid or expired",
    "status": 401,
    "request_id": "req_1234567890"
  }
}`} 
            />
          </CardContent>
        </Card>
      </section>
      
      {/* Chat Completion Section */}
      <section id="chat-completion" className="mb-10">
        <h2 className="text-xl font-bold mb-4">Chat Completion</h2>
        <p className="mb-4">
          Generate chat completions using GPT models optimized for conversational interfaces.
        </p>
        
        <EndpointCard 
          method="POST"
          endpoint="/api/v1/chat/completions"
          description="Generate a completion for a chat conversation using a GPT model."
          parameters={[
            {
              name: "model",
              type: "string",
              required: true,
              description: "ID of the model to use"
            },
            {
              name: "messages",
              type: "array",
              required: true,
              description: "Array of message objects"
            },
            {
              name: "temperature",
              type: "number",
              required: false,
              description: "Sampling temperature (0-1)"
            },
            {
              name: "max_tokens",
              type: "integer",
              required: false,
              description: "Maximum tokens to generate"
            },
            {
              name: "format",
              type: "string",
              required: false,
              description: "Response format (default: 'text')"
            }
          ]}
          curlExample={`curl -X POST https://api.moneybot.io/v1/chat/completions \\
  -H "Content-Type: application/json" \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "system", "content": "You are a helpful financial assistant."},
      {"role": "user", "content": "What is the best way to save for retirement?"}
    ],
    "temperature": 0.7,
    "max_tokens": 300
  }'`}
          swiftExample={`import Foundation

struct Message: Codable {
    let role: String
    let content: String
}

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [Message]
    let temperature: Float
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

func sendChatCompletionRequest() {
    let url = URL(string: "https://api.moneybot.io/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
    
    let chatRequest = ChatCompletionRequest(
        model: "gpt-3.5-turbo",
        messages: [
            Message(role: "system", content: "You are a helpful financial assistant."),
            Message(role: "user", content: "What is the best way to save for retirement?")
        ],
        temperature: 0.7,
        maxTokens: 300
    )
    
    let encoder = JSONEncoder()
    request.httpBody = try? encoder.encode(chatRequest)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle response
    }
    
    task.resume()
}`}
          jsExample={`async function sendChatCompletionRequest() {
  const response = await fetch('https://api.moneybot.io/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_API_KEY'
    },
    body: JSON.stringify({
      model: 'gpt-3.5-turbo',
      messages: [
        {role: 'system', content: 'You are a helpful financial assistant.'},
        {role: 'user', content: 'What is the best way to save for retirement?'}
      ],
      temperature: 0.7,
      max_tokens: 300
    })
  });
  
  const data = await response.json();
  console.log(data);
}`}
          responseExample={`{
  "id": "chatcmpl-7NtrUz8HlTS9D",
  "object": "chat.completion",
  "created": 1686901334,
  "model": "gpt-3.5-turbo",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "The best way to save for retirement depends on your specific situation, but here are some general recommendations:\\n\\n1. **Start early**: The power of compound interest means the earlier you start, the more your money can grow.\\n\\n2. **Utilize employer-sponsored plans**: If your employer offers a 401(k) or similar plan, especially with matching contributions, prioritize this option.\\n\\n3. **Open an IRA**: Individual Retirement Accounts (traditional or Roth) offer tax advantages for retirement savings.\\n\\n4. **Diversify investments**: Spread your retirement savings across different asset classes based on your age and risk tolerance.\\n\\n5. **Consistently contribute**: Set up automatic contributions to ensure regular savings.\\n\\n6. **Maximize tax-advantaged accounts**: Contribute to the annual limit in tax-advantaged retirement accounts before investing in taxable accounts.\\n\\n7. **Consider health savings accounts (HSAs)**: If eligible, HSAs offer triple tax advantages when used for healthcare expenses in retirement.\\n\\nConsult with a financial advisor to create a personalized retirement strategy based on your goals, timeframe, and financial situation."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 37,
    "completion_tokens": 219,
    "total_tokens": 256
  }
}`}
        />
        
        <Card className="bg-[#F7F7F8]">
          <CardContent className="p-4">
            <h3 className="font-medium mb-3">iOS-Specific Considerations</h3>
            <p className="text-sm mb-2">When implementing chat completions in iOS applications:</p>
            <ul className="list-disc pl-5 text-sm space-y-1">
              <li>Implement proper error handling for network issues common on mobile devices</li>
              <li>Consider implementing streaming responses for better user experience</li>
              <li>Cache responses when appropriate to reduce API usage</li>
              <li>Implement retry logic with exponential backoff for failed requests</li>
            </ul>
          </CardContent>
        </Card>
      </section>
      
      {/* Message History Section */}
      <section id="message-history" className="mb-10">
        <h2 className="text-xl font-bold mb-4">Message History</h2>
        <p className="mb-4">
          Retrieve previous messages and conversations to maintain context between app sessions.
        </p>
        
        <EndpointCard 
          method="GET"
          endpoint="/api/v1/messages"
          description="Retrieve message history for the authenticated user, optionally filtered by conversation ID."
          parameters={[
            {
              name: "conversation_id",
              type: "string",
              required: false,
              description: "Filter messages by conversation ID"
            }
          ]}
          curlExample={`curl -X GET "https://api.moneybot.io/v1/messages?conversation_id=conv_123456" \\
  -H "Authorization: Bearer YOUR_API_KEY"`}
          swiftExample={`import Foundation

func getMessageHistory(conversationId: String?) {
    var urlString = "https://api.moneybot.io/v1/messages"
    if let conversationId = conversationId {
        urlString += "?conversation_id=\\(conversationId)"
    }
    
    let url = URL(string: urlString)!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle response
    }
    
    task.resume()
}`}
          jsExample={`async function getMessageHistory(conversationId) {
  let url = 'https://api.moneybot.io/v1/messages';
  if (conversationId) {
    url += \`?conversation_id=\${conversationId}\`;
  }
  
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Authorization': 'Bearer YOUR_API_KEY'
    }
  });
  
  const data = await response.json();
  console.log(data);
}`}
          responseExample={`{
  "data": [
    {
      "id": 1,
      "userId": 101,
      "role": "user",
      "content": "What is the best way to save for retirement?",
      "timestamp": "2023-06-15T10:30:45Z",
      "model": "gpt-3.5-turbo",
      "conversationId": "conv_123456"
    },
    {
      "id": 2,
      "userId": 101,
      "role": "assistant",
      "content": "The best way to save for retirement depends on your specific situation...",
      "timestamp": "2023-06-15T10:30:50Z",
      "model": "gpt-3.5-turbo",
      "conversationId": "conv_123456"
    }
  ],
  "meta": {
    "total": 2,
    "conversation_id": "conv_123456"
  }
}`}
        />
      </section>
      
      {/* Model Selection Section */}
      <section id="model-selection" className="mb-10">
        <h2 className="text-xl font-bold mb-4">Model Selection</h2>
        <p className="mb-4">
          List available models to use with the API.
        </p>
        
        <EndpointCard 
          method="GET"
          endpoint="/api/v1/models"
          description="Get a list of available models that can be used with the API."
          curlExample={`curl -X GET https://api.moneybot.io/v1/models \\
  -H "Authorization: Bearer YOUR_API_KEY"`}
          swiftExample={`import Foundation

func getAvailableModels() {
    let url = URL(string: "https://api.moneybot.io/v1/models")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle response
    }
    
    task.resume()
}`}
          jsExample={`async function getAvailableModels() {
  const response = await fetch('https://api.moneybot.io/v1/models', {
    method: 'GET',
    headers: {
      'Authorization': 'Bearer YOUR_API_KEY'
    }
  });
  
  const data = await response.json();
  console.log(data);
}`}
          responseExample={`{
  "data": [
    {
      "id": "gpt-4o",
      "name": "GPT-4o",
      "description": "Latest OpenAI model with improved capabilities"
    },
    {
      "id": "gpt-3.5-turbo",
      "name": "GPT-3.5 Turbo",
      "description": "Standard model with good performance/cost balance"
    }
  ]
}`}
        />
      </section>
      
      {/* iOS Integration Section */}
      <section id="ios-examples" className="mb-10">
        <h2 className="text-xl font-bold mb-4">iOS Integration</h2>
        <p className="mb-4">
          Implementation examples specifically for the MoneyBot iOS application.
        </p>
        
        <Card className="bg-[#F7F7F8] mb-6">
          <CardContent className="p-4">
            <h3 className="font-medium mb-3">Swift Integration Example</h3>
            <CodeBlock 
              code={`import Foundation
import Combine

class ChatService {
    private let apiKey: String
    private let baseURL = "https://api.moneybot.io/v1"
    private var cancellables = Set<AnyCancellable>()
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func sendMessage(_ message: String, 
                    history: [Message] = [],
                    completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let url = URL(string: "\\(baseURL)/chat/completions") else {
            completion(.failure(ServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \\(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Create messages array with history and new message
        var messages = history
        messages.append(Message(role: "user", content: message))
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages.map { ["role": $0.role, "content": $0.content] },
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\\.data)
            .decode(type: ChatCompletionResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case let .failure(error) = result {
                        completion(.failure(error))
                    }
                },
                receiveValue: { response in
                    if let message = response.choices.first?.message.content {
                        completion(.success(message))
                    } else {
                        completion(.failure(ServiceError.noResponseData))
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    enum ServiceError: Error {
        case invalidURL
        case noResponseData
    }
}

// Model definitions
struct Message: Codable {
    let role: String
    let content: String
}

struct ChatCompletionResponse: Codable {
    let id: String
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
}`} 
              language="swift"
            />
          </CardContent>
        </Card>
        
        <Card className="bg-[#F7F7F8]">
          <CardContent className="p-4">
            <h3 className="font-medium mb-3">SwiftUI Implementation</h3>
            <CodeBlock 
              code={`import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    
    private let chatService: ChatService
    
    init(apiKey: String) {
        self.chatService = ChatService(apiKey: apiKey)
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(id: UUID().uuidString, 
                                    role: "user", 
                                    content: inputText, 
                                    timestamp: Date())
        messages.append(userMessage)
        
        let currentInput = inputText
        inputText = ""
        isLoading = true
        
        // Convert view messages to API messages
        let historyMessages = messages.map { Message(role: $0.role, content: $0.content) }
        
        chatService.sendMessage(currentInput, history: historyMessages) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    let assistantMessage = ChatMessage(id: UUID().uuidString,
                                                     role: "assistant",
                                                     content: response,
                                                     timestamp: Date())
                    self?.messages.append(assistantMessage)
                    
                case .failure(let error):
                    // Handle error - show alert, etc.
                    print("Error: \\(error.localizedDescription)")
                    let errorMessage = ChatMessage(id: UUID().uuidString,
                                                role: "system",
                                                content: "Error: \\(error.localizedDescription)",
                                                timestamp: Date())
                    self?.messages.append(errorMessage)
                }
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id: String
    let role: String
    let content: String
    let timestamp: Date
}

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel(apiKey: "YOUR_API_KEY")
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                    }
                    
                    if viewModel.isLoading {
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
                TextField("Message", text: $viewModel.inputText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .onSubmit {
                        viewModel.sendMessage()
                    }
                
                Button(action: viewModel.sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            }
            .padding()
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == "user" {
                Spacer()
            }
            
            VStack(alignment: message.role == "user" ? .trailing : .leading) {
                Text(message.content)
                    .padding(12)
                    .background(message.role == "user" ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.role == "user" ? .white : .primary)
                    .cornerRadius(16)
            }
            .frame(maxWidth: 300, alignment: message.role == "user" ? .trailing : .leading)
            
            if message.role != "user" {
                Spacer()
            }
        }
    }
}`} 
              language="swift"
            />
          </CardContent>
        </Card>
      </section>
      
      {/* Mobile Optimizations Section */}
      <section id="mobile-optimizations" className="mb-10">
        <h2 className="text-xl font-bold mb-4">Mobile Optimizations</h2>
        <p className="mb-4">
          Best practices for integrating the API with mobile applications.
        </p>
        
        <Card className="border border-[#E5E5E5] mb-6">
          <CardContent className="p-4">
            <h3 className="font-medium mb-3">Network Handling</h3>
            <ul className="list-disc pl-5 space-y-2">
              <li>Implement proper error handling for intermittent connectivity issues</li>
              <li>Use exponential backoff for retrying failed requests</li>
              <li>Consider implementing request queuing for offline operation</li>
              <li>Monitor network type (WiFi/Cellular) and adjust behavior accordingly</li>
            </ul>
          </CardContent>
        </Card>
        
        <Card className="border border-[#E5E5E5] mb-6">
          <CardContent className="p-4">
            <h3 className="font-medium mb-3">UI/UX Considerations</h3>
            <ul className="list-disc pl-5 space-y-2">
              <li>Show loading indicators during API requests</li>
              <li>Implement message typing animations for a more natural chat experience</li>
              <li>Cache responses to reduce API calls and improve performance</li>
              <li>Implement a graceful timeout mechanism for slow responses</li>
              <li>Use optimistic UI updates for improved perceived performance</li>
            </ul>
          </CardContent>
        </Card>
        
        <Card className="border border-[#E5E5E5]">
          <CardContent className="p-4">
            <h3 className="font-medium mb-3">Battery & Data Usage</h3>
            <ul className="list-disc pl-5 space-y-2">
              <li>Batch API requests when possible to reduce network overhead</li>
              <li>Implement rate limiting to prevent excessive API calls</li>
              <li>Consider response streaming for long responses to improve user experience</li>
              <li>Use compression when appropriate to reduce data usage</li>
              <li>Monitor and optimize token usage to reduce costs</li>
            </ul>
          </CardContent>
        </Card>
      </section>
      
      {/* FAQ Section */}
      <section id="faq" className="mb-10">
        <h2 className="text-xl font-bold mb-4">FAQ</h2>
        
        <div className="space-y-4">
          <Card className="border border-[#E5E5E5]">
            <CardContent className="p-4">
              <h3 className="font-medium mb-2">How do I get an API key?</h3>
              <p>For development purposes, you can use the demo API key found in the API Playground. For production use, please contact the MoneyBot team to get your own API key.</p>
            </CardContent>
          </Card>
          
          <Card className="border border-[#E5E5E5]">
            <CardContent className="p-4">
              <h3 className="font-medium mb-2">What is the rate limit for API calls?</h3>
              <p>The API is rate limited to 60 requests per minute per API key. If you exceed this limit, you will receive a 429 Too Many Requests response.</p>
            </CardContent>
          </Card>
          
          <Card className="border border-[#E5E5E5]">
            <CardContent className="p-4">
              <h3 className="font-medium mb-2">How do I report issues with the API?</h3>
              <p>If you encounter any issues with the API, please contact support at support@moneybot.io or open an issue on the GitHub repository.</p>
            </CardContent>
          </Card>
          
          <Card className="border border-[#E5E5E5]">
            <CardContent className="p-4">
              <h3 className="font-medium mb-2">Does the API support streaming responses?</h3>
              <p>Currently, the API does not support streaming responses. All responses are returned as a single JSON object. Streaming support is planned for a future release.</p>
            </CardContent>
          </Card>
          
          <Card className="border border-[#E5E5E5]">
            <CardContent className="p-4">
              <h3 className="font-medium mb-2">How is conversation history handled?</h3>
              <p>The API automatically stores message history associated with your API key. You can retrieve previous messages using the /messages endpoint with an optional conversation_id parameter.</p>
            </CardContent>
          </Card>
        </div>
      </section>
    </div>
  );
};

export default Home;
