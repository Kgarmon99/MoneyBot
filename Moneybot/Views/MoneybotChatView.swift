import SwiftUI

struct MoneybotChatView: View {
    @StateObject private var moneybotService = MoneybotService.shared
    @State private var newMessage = ""
    @State private var scrollProxy: ScrollViewProxy? = nil
    @FocusState private var isInputFocused: Bool
    
    // Colors for chat bubbles
    private let userBubbleColor = Color.green.opacity(0.2)
    private let botBubbleColor = Color.gray.opacity(0.1)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with logo and title
            HStack {
                Image("new-moneybot-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                
                Text("Moneybot Co-Pilot")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    moneybotService.clearChat()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 5)
            
            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(moneybotService.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        // Ghost bubble for when bot is typing
                        if moneybotService.isLoading {
                            HStack {
                                BotTypingIndicator()
                                Spacer()
                            }
                            .id("loadingIndicator")
                        }
                    }
                    .padding()
                }
                .onChange(of: moneybotService.messages.count) { _ in
                    withAnimation {
                        if let lastMessage = moneybotService.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: moneybotService.isLoading) { isLoading in
                    if isLoading {
                        withAnimation {
                            proxy.scrollTo("loadingIndicator", anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    scrollProxy = proxy
                    if let lastMessage = moneybotService.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            // Bottom input area
            VStack(spacing: 0) {
                Divider()
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.1))
                        
                        TextField("Ask Moneybot something...", text: $newMessage)
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .focused($isInputFocused)
                            .submitLabel(.send)
                            .onSubmit {
                                sendMessage()
                            }
                    }
                    .frame(height: 40)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.green)
                    }
                    .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || moneybotService.isLoading)
                    .opacity((newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || moneybotService.isLoading) ? 0.5 : 1.0)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color.white)
        }
        .navigationTitle("Money Co-Pilot")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
    
    private func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty && !moneybotService.isLoading else { return }
        
        let messageToSend = trimmedMessage
        newMessage = ""
        
        // Hide keyboard after sending
        isInputFocused = false
        
        // Send message to service
        moneybotService.sendMessage(messageToSend) { result in
            // Handle any errors if needed
            if case .failure(let error) = result {
                print("Error communicating with Moneybot AI: \(error)")
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
                
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.1), lineWidth: 1)
                    )
                    .frame(maxWidth: 280, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .bottom, spacing: 8) {
                        // Bot avatar
                        Image("new-moneybot-logo")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .clipShape(Circle())
                        
                        Text(message.content)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .frame(maxWidth: 280, alignment: .leading)
                    }
                    
                    // Timestamp below bot message
                    Text(formatTimestamp(message.timestamp))
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .padding(.leading, 36)
                }
                
                Spacer()
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct BotTypingIndicator: View {
    @State private var offsetOne: CGFloat = 0
    @State private var offsetTwo: CGFloat = 0
    @State private var offsetThree: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 8) {
            // Bot avatar
            Image("new-moneybot-logo")
                .resizable()
                .frame(width: 28, height: 28)
                .clipShape(Circle())
            
            // Typing indicator
            HStack(spacing: 5) {
                Circle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 6, height: 6)
                    .offset(y: offsetOne)
                Circle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 6, height: 6)
                    .offset(y: offsetTwo)
                Circle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 6, height: 6)
                    .offset(y: offsetThree)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever()) {
                offsetOne = -5
            }
            
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.2)) {
                offsetTwo = -5
            }
            
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.4)) {
                offsetThree = -5
            }
        }
    }
}

struct MoneybotChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MoneybotChatView()
        }
    }
}
