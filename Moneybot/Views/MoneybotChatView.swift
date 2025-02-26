import SwiftUI
import Combine

struct MoneybotChatView: View {
    @StateObject private var moneybotService = MoneybotService()
    @State private var messageText: String = ""
    @State private var showingSuggestions: Bool = true
    @State private var scrollToBottom: Bool = false
    @Binding var user: User
    
    private let suggestionQuestions = [
        "How can I start building an emergency fund?",
        "What's the difference between saving and investing?",
        "How should I prioritize paying off debt?",
        "Can you explain compound interest?",
        "How much should I save for retirement?"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(moneybotService.messages.filter { $0.role != .system }) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        if moneybotService.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                    .scaleEffect(1.2)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(20)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                    .padding(.vertical)
                }
                .onAppear {
                    scrollToBottom = true
                }
                .onChange(of: moneybotService.messages.count) { _ in
                    withAnimation {
                        if let lastMessage = moneybotService.messages.last {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                    
                    // Add XP if user received new AI message
                    if let lastMessage = moneybotService.messages.last, lastMessage.role == .assistant {
                        if lastMessage.content != "I'm having trouble right now. Please try again later." {
                            user.xp += 10 // Award XP for each meaningful interaction
                        }
                    }
                }
            }
            
            if showingSuggestions {
                suggestionView
            }
            
            inputBar
        }
        .background(Color(.systemGray6))
        .navigationTitle("MoneyBot Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            user.chatInteractions += 1
            
            // Check for earned achievements
            if user.chatInteractions == 1 {
                user.achievements.append(Achievement(
                    title: "First Chat",
                    description: "Started your first conversation with Moneybot",
                    icon: "message.fill",
                    xpValue: 50
                ))
                user.xp += 50
            } else if user.chatInteractions == 5 {
                user.achievements.append(Achievement(
                    title: "Curious Mind",
                    description: "Had 5 conversations with Moneybot",
                    icon: "lightbulb.fill",
                    xpValue: 100
                ))
                user.xp += 100
            }
        }
    }
    
    private var suggestionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(suggestionQuestions, id: \.self) { question in
                    Button(action: {
                        messageText = question
                        sendMessage()
                    }) {
                        Text(question)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray5))
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var inputBar: some View {
        HStack(alignment: .center, spacing: 10) {
            Button(action: {
                withAnimation {
                    showingSuggestions.toggle()
                }
            }) {
                Image(systemName: showingSuggestions ? "chevron.down" : "lightbulb")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                    .padding(8)
                    .background(Circle().fill(Color(.systemGray5)))
            }
            
            TextField("Ask Moneybot...", text: $messageText)
                .padding(12)
                .background(Color(.systemGray5))
                .cornerRadius(20)
                .submitLabel(.send)
                .onSubmit {
                    sendMessage()
                }
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(messageText.isEmpty ? Color(.systemGray3) : .green)
            }
            .disabled(messageText.isEmpty || moneybotService.isLoading)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty, !moneybotService.isLoading else { return }
        
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        moneybotService.sendMessage(message)
        
        // Hide suggestions after sending a message
        withAnimation {
            showingSuggestions = false
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    private var isUser: Bool {
        message.role == .user
    }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.role.displayName)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                
                Text(message.content)
                    .padding(12)
                    .background(
                        isUser ?
                        LinearGradient(
                            colors: [.green, Color.green.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color(.systemGray5), Color(.systemGray4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(isUser ? .white : .primary)
                    .cornerRadius(18)
            }
            .padding(.horizontal)
            
            if !isUser { Spacer() }
        }
    }
}

struct Achievement {
    var id = UUID()
    var title: String
    var description: String
    var icon: String
    var xpValue: Int
    var dateEarned: Date = Date()
}

extension User {
    // These would typically be in the User model, but adding for illustration
    var chatInteractions: Int {
        get { UserDefaults.standard.integer(forKey: "chatInteractions") }
        set { UserDefaults.standard.set(newValue, forKey: "chatInteractions") }
    }
    
    mutating func addAchievement(_ achievement: Achievement) {
        achievements.append(achievement)
        xp += achievement.xpValue
    }
}
