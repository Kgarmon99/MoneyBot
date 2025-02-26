import SwiftUI

struct LearnView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var user: User
    @State private var currentTipIndex = 0
    @State private var showConfetti = false
    @State private var showXPGain = false
    
    @State private var contentType: ContentType = .visuals
    
    enum ContentType {
        case visuals
        case audio
        case quotes
        case tips
        case moneybot
    }
    
    let audioContent = [
        AudioContent(
            title: "Path to Success",
            speaker: "Michael Jordan",
            duration: "2:15",
            description: "Michael Jordan shares his insights on dedication, perseverance and the mindset of a champion",
            category: .mindset
        ),
        AudioContent(
            title: "Dream Big",
            speaker: "Kobe Bryant",
            duration: "1:45",
            description: "Kobe Bryant on the importance of dreaming big and working hard to achieve your goals",
            category: .mindset
        ),
        AudioContent(
            title: "Investing Wisdom",
            speaker: "Warren Buffett",
            duration: "3:30",
            description: "Warren Buffett shares timeless investing principles and wisdom",
            category: .investing
        ),
        AudioContent(
            title: "Think Different",
            speaker: "Steve Jobs",
            duration: "1:01",
            description: "Here's to the crazy ones. The misfits. The rebels. The troublemakers...",
            category: .mindset
        )
    ]
    
    func playHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    let tips = FinancialContent.tips
    let quotes = FinancialContent.quotes
    
    var currentContent: some View {
        Group {
            switch contentType {
            case .moneybot:
                MoneybotChatView(user: $user)
            case .quotes:
                VStack {
                    QuoteCard(quote: quotes[currentTipIndex % quotes.count])
                    NavigationControls(currentIndex: $currentTipIndex, totalItems: quotes.count)
                }
            case .visuals:
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        ForEach(0..<50, id: \.self) { i in
                            let index = i % visualContent.count
                            VisualCard(index: index, visualContent: visualContent)
                                .padding(.horizontal)
                                .shadow(color: Color.black.opacity(0.05), radius: 10)
                                .transition(.opacity)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .refreshable {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            case .audio:
                VStack {
                    AudioCard(audio: audioContent[currentTipIndex % audioContent.count])
                    NavigationControls(currentIndex: $currentTipIndex, totalItems: audioContent.count)
                }
            case .tips:
                VStack {
                    TipCard(tip: tips[currentTipIndex % tips.count])
                    NavigationControls(currentIndex: $currentTipIndex, totalItems: tips.count)
                }
            }
        }
    }
    
    let visualContent = [
        VisualContent(image: "ShowMetheMoney", title: "Show Me The Money!", description: "When you're eagerly waiting for payday 💰"),
        VisualContent(image: "DoOneThingToday", title: "Daily Progress", description: "Focus on making one positive financial move each day 🎯"),
        VisualContent(image: "Money=Defense", title: "Financial Defense", description: "Build your financial security through smart money management 🛡️"),
        VisualContent(image: "CompoundInterest", title: "Compound Interest", description: "The eighth wonder of the world - let your money work for you 📈")
    ]
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            // Animated background effects
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.green.opacity(0.08))
                    .frame(width: 200)
                    .blur(radius: 50)
                    .offset(x: CGFloat.random(in: -100...100),
                            y: CGFloat.random(in: -100...100))
                    .hueRotation(.degrees(Double(index) * 60))
            }
            
            VStack(spacing: 30) {
                // Moneybot Character
                Image("new-moneybot-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .padding(.top, 20)
                    .shadow(color: Color.green.opacity(0.5), radius: 10)
                    .overlay(
                        Image("new-moneybot-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .blur(radius: 4)
                            .opacity(0.3)
                    )
                
                Text("Today's Money Tip")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Content Type Picker
                Picker("Content Type", selection: $contentType) {
                    Text("Visuals").tag(ContentType.visuals)
                    Text("Audio").tag(ContentType.audio)
                    Text("Quotes").tag(ContentType.quotes)
                    Text("Tips").tag(ContentType.tips)
                    Text("Moneybot").tag(ContentType.moneybot)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Content Card
                currentContent
                    .padding(.horizontal)
                    .transition(.slide)
                
                // Spacer to maintain layout
                Spacer()
                    .frame(height: 20)
                
                // Complete Button
                Button(action: {
                    showConfetti = true
                    withAnimation(.spring()) {
                        showXPGain = true
                        user.xp += 50
                    }
                    playHapticFeedback()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showXPGain = false
                        dismiss()
                    }
                }) {
                    HStack {
                        Text("Got it!")
                        Text("+50 XP")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green)
                    .cornerRadius(25)
                    .shadow(color: Color.green.opacity(0.3), radius: 10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            
            if showConfetti {
                ConfettiView()
            }
        }
        .navigationBarItems(trailing: Button("Close") {
            dismiss()
        })
    }
    
    func nextTip() {
        withAnimation {
            currentTipIndex = (currentTipIndex + 1) % tips.count
        }
    }
    
    func previousTip() {
        withAnimation {
            currentTipIndex = (currentTipIndex - 1 + tips.count) % tips.count
        }
    }
}

struct TipCard: View {
    let tip: FinancialTip
    @State private var isAnimating = false
    @State private var showGlow = false
    @State private var rotationAngle = 0.0
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated icon
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 80 + CGFloat(i * 20))
                        .blur(radius: CGFloat(i * 2))
                        .opacity(showGlow ? 0.8 : 0.3)
                }
                
                Image(systemName: tip.icon)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.green)
                    .shadow(color: .green.opacity(0.5), radius: 10)
                    .rotationEffect(.degrees(rotationAngle))
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.green.opacity(0.8), .green.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 90, height: 90)
                    )
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 16) {
                    Text(tip.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(tip.content)
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .lineSpacing(6)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 500)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [.white, Color.green.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        LinearGradient(
                            colors: [.green.opacity(0.7), .green.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: .green.opacity(0.2), radius: 15)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever()) {
                showGlow = true
                isAnimating = true
            }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

struct ConfettiView: View {
    var body: some View {
        ZStack {
            ForEach(0..<50) { _ in
                Circle()
                    .fill(Color.random)
                    .frame(width: 10, height: 10)
                    .modifier(ParticleModifier())
            }
        }
    }
}

extension Color {
    static var random: Color {
        Color(red: Double.random(in: 0...1),
              green: Double.random(in: 0...1),
              blue: Double.random(in: 0...1))
    }
}

struct ParticleModifier: ViewModifier {
    @State private var time = 0.0
    let duration = 1.0
    
    func body(content: Content) -> some View {
        content
            .offset(x: CGFloat.random(in: -300...300),
                   y: CGFloat.random(in: -50...50))
            .onAppear {
                withAnimation(.easeOut(duration: duration)) {
                    time = duration
                }
            }
    }
}
struct NavigationControls: View {
    @Binding var currentIndex: Int
    let totalItems: Int
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                withAnimation {
                    currentIndex = (currentIndex - 1 + totalItems) % totalItems
                }
            }) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.green)
            }
            
            Button(action: {
                withAnimation {
                    currentIndex = (currentIndex + 1) % totalItems
                }
            }) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
}
