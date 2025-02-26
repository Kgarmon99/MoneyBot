import SwiftUI

struct MoneybotChatView: View {
    @StateObject private var service = MoneybotService()
    @State private var messageText = ""
    @State private var showingSuggestions = true
    @Binding var user: User
    @State private var isCalculatorShowing = false
    @State private var calculatorType: CalculatorType = .compound
    
    enum CalculatorType {
        case compound
        case savings
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat messages
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(service.messages.filter { $0.role != .system }) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        // Loading indicator
                        if service.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                .scaleEffect(1.2)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding()
                }
                .onChange(of: service.messages.count) { _ in
                    withAnimation {
                        if let lastMessage = service.messages.last(where: { $0.role != .system }) {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                    
                    // Award XP for meaningful interactions
                    if let lastMessage = service.messages.last, 
                       lastMessage.role == .assistant,
                       !lastMessage.content.contains("technical difficulties") {
                        user.xp += 10
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            
            // Suggested follow-ups
            if showingSuggestions && !service.suggestedFollowUps.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(service.suggestedFollowUps, id: \.self) { question in
                            Button(action: {
                                messageText = question
                                sendMessage()
                            }) {
                                Text(question)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemGray5))
                                    )
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
                .background(Color(.systemGray6))
            }
            
            // Calculator tools
            if isCalculatorShowing {
                VStack(spacing: 12) {
                    HStack {
                        Text("Financial Calculator")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                isCalculatorShowing = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Picker("Calculator Type", selection: $calculatorType) {
                        Text("Compound Interest").tag(CalculatorType.compound)
                        Text("Savings Goal").tag(CalculatorType.savings)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if calculatorType == .compound {
                        CompoundInterestCalculator(service: service)
                    } else {
                        SavingsGoalCalculator(service: service)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
            
            // Message input
            messageInputView
        }
        .onAppear {
            // Track usage in user stats
            if user.chatSessions == nil {
                user.chatSessions = 1
            } else {
                user.chatSessions! += 1
            }
            
            // Check for achievement
            if user.chatSessions == 1 {
                let achievement = Achievement(
                    title: "First Chat",
                    description: "Started your first conversation with Moneybot",
                    icon: "message.circle.fill",
                    unlocked: true
                )
                
                if !user.achievements.contains(where: { $0.title == achievement.title }) {
                    user.achievements.append(achievement)
                    user.xp += 50
                }
            }
        }
    }
    
    private var messageInputView: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Button(action: {
                withAnimation {
                    showingSuggestions.toggle()
                }
            }) {
                Image(systemName: showingSuggestions ? "chevron.down" : "lightbulb")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color(.systemGray5))
                    )
            }
            
            Button(action: {
                withAnimation {
                    isCalculatorShowing.toggle()
                }
            }) {
                Image(systemName: "function")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color(.systemGray5))
                    )
            }
            
            TextField("Ask Moneybot...", text: $messageText)
                .padding(12)
                .background(Color(.systemGray5))
                .cornerRadius(20)
                .submitLabel(.send)
                .onSubmit(sendMessage)
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(messageText.isEmpty ? Color(.systemGray3) : .green)
            }
            .disabled(messageText.isEmpty || service.isLoading)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty, !service.isLoading else { return }
        
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        
        withAnimation {
            showingSuggestions = false
        }
        
        service.sendMessage(text)
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 2) {
                Text(message.role.displayName)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                
                Text(message.content)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.role == .user ?
                            LinearGradient(
                                gradient: Gradient(colors: [.green, Color.green.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            Color(.systemGray5)
                    )
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .cornerRadius(18)
            }
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

struct CompoundInterestCalculator: View {
    let service: MoneybotService
    @State private var principal: String = "1000"
    @State private var rate: String = "7"
    @State private var years: String = "10"
    @State private var monthlyContribution: String = "0"
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Initial amount:")
                TextField("$", text: $principal)
                    .keyboardType(.decimalPad)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            HStack {
                Text("Interest rate (%):")
                TextField("%", text: $rate)
                    .keyboardType(.decimalPad)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            HStack {
                Text("Years:")
                TextField("years", text: $years)
                    .keyboardType(.numberPad)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            HStack {
                Text("Monthly add:")
                TextField("$", text: $monthlyContribution)
                    .keyboardType(.decimalPad)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            Button(action: calculateAndSend) {
                Text("Calculate")
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
    }
    
    private func calculateAndSend() {
        let principalValue = Double(principal) ?? 1000
        let rateValue = Double(rate) ?? 7
        let yearsValue = Int(years) ?? 10
        let monthlyValue = Double(monthlyContribution) ?? 0
        
        let result = service.calculateCompoundInterest(
            principal: principalValue,
            rate: rateValue,
            years: yearsValue,
            monthlyContribution: monthlyValue
        )
        
        service.sendMessage("Calculate compound interest with principal $\(principal), rate \(rate)%, time \(years) years, and monthly contribution $\(monthlyContribution)")
    }
}

struct SavingsGoalCalculator: View {
    let service: MoneybotService
    @State private var goal: String = "10000"
    @State private var months: String = "24"
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Goal amount:")
                TextField("$", text: $goal)
                    .keyboardType(.decimalPad)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            HStack {
                Text("Months to goal:")
                TextField("months", text: $months)
                    .keyboardType(.numberPad)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            Button(action: calculateAndSend) {
                Text("Calculate")
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
    }
    
    private func calculateAndSend() {
        let goalValue = Double(goal) ?? 10000
        let monthsValue = Int(months) ?? 24
        
        let result = service.generateSavingsPlan(
            goal: goalValue,
            timeframe: monthsValue
        )
        
        service.sendMessage("I want to save $\(goal) in \(months) months. What's my savings plan?")
    }
}

// Extended User model with chat tracking
extension User {
    var chatSessions: Int? {
        get { UserDefaults.standard.integer(forKey: "userChatSessions") }
        set { 
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: "userChatSessions")
            }
        }
    }
}
