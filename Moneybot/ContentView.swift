import SwiftUI
import CoreData

struct ContentView: View {
    @State private var animate = false
    @State private var showReward = false
    @State private var lastReward = ""
    @State private var colorScheme: ColorScheme = .light
    @AppStorage("userColorScheme") private var savedColorScheme: String = "light"
    @State private var user: User = {
        let (savedStreak, lastActiveDate) = User.loadSavedStreak()
        let savedGoals = User.loadSavedGoals()
        return User(level: 1, xp: 150, streak: savedStreak, lastActiveDate: lastActiveDate, activeGoals: savedGoals)
    }()
    @State private var showChallengePicker = false
    @State private var showFinanceLesson = false
    @State private var selectedTab = 0
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    init() {
        UINavigationBar.appearance().tintColor = .green
    }

    let primaryGreen = Color(red: 0.0, green: 0.8, blue: 0.4)
    let secondaryGreen = Color(red: 0.0, green: 0.7, blue: 0.3)
    let glowGreen = Color(red: 0.0, green: 0.9, blue: 0.4)
    let gradientStart = Color.white
    let gradientEnd = Color(red: 0.95, green: 0.98, blue: 0.96)
    let cardBackground = Color.white

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        // Reset selected tab to home when returning to root view
                        selectedTab = 0
                        // Schedule notifications if permissions are granted
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            user.scheduleNotifications()
                        }
                    }
                    .sheet(isPresented: $showOnboarding, onDismiss: {
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        if !user.activeGoals.isEmpty {
                            selectedTab = 3 // Switch to Progress tab
                        }
                    }) {
                        OnboardingView(user: $user)
                    }



                VStack(spacing: 0) {
                    // Fixed Header
                    HStack(spacing: 16) {
                        StreakBadge(streak: user.streak)
                            .onTapGesture {
                                selectedTab = 3 // Switch to Progress tab
                            }
                        Spacer()
                        Image("new-moneybot-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .shadow(color: Color.green.opacity(0.5), radius: 10)
                            .overlay(
                                Image("new-moneybot-logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 45)
                                    .blur(radius: 4)
                                    .opacity(0.3)
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    colorScheme = colorScheme == .light ? .dark : .light
                                }
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                        Spacer()
                        LevelCircle(level: user.level, xp: user.xp)
                            .onTapGesture {
                                selectedTab = 3 // Switch to Progress tab
                            }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.white, Color.green.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.3), Color.green.opacity(0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.green.opacity(0.2), radius: 10, y: 5)

                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack {
                            // Background aura
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 300, height: 300)
                                .blur(radius: 80)
                                .offset(y: -100)
                                .hueRotation(.degrees(animate ? 360 : 0))
                                .animation(Animation.linear(duration: 10).repeatForever(autoreverses: false), value: animate)
                                .onAppear { animate = true }

                            VStack(spacing: 24) {
                                // Feature Highlights
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        FeatureBadge(
                                            icon: "trophy.fill",
                                            value: "\(user.streak)🔥",
                                            label: "Day Streak",
                                            color: .orange
                                        )
                                        .onTapGesture {
                                            selectedTab = 3 // Progress tab
                                        }
                                        FeatureBadge(
                                            icon: "sparkles",
                                            value: "Level \(user.level)",
                                            label: "Current Level",
                                            color: .purple
                                        )
                                        .onTapGesture {
                                            selectedTab = 3 // Progress tab
                                        }
                                        FeatureBadge(
                                            icon: "chart.line.uptrend.xyaxis",
                                            value: "+\(user.xp)XP",
                                            label: "Experience",
                                            color: .blue
                                        )
                                        .onTapGesture {
                                            selectedTab = 3 // Progress tab
                                        }
                                        FeatureBadge(
                                            icon: "target",
                                            value: "\(user.activeGoals.count)",
                                            label: "Active Goals",
                                            color: .green
                                        )
                                        .onTapGesture {
                                            selectedTab = 3 // Progress tab
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .padding(.top, 20)

                                // Daily Challenge with Enhanced Visibility
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Today's Money Move")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(primaryGreen)

                                        Image(systemName: "sparkles")
                                            .font(.system(size: 20))
                                            .foregroundColor(glowGreen)
                                            .rotationEffect(.degrees(animate ? 20 : -20))
                                            .animation(
                                                Animation.easeInOut(duration: 1.5)
                                                    .repeatForever(autoreverses: true),
                                                value: animate
                                            )
                                    }
                                    .padding(.vertical, 8)
                                    .shadow(color: glowGreen.opacity(0.5), radius: 8)

                                    if user.dailyChallenge.isEmpty {
                                        Button(action: {
                                            showChallengePicker = true
                                        }) {
                                            HStack(spacing: 12) {
                                                Image(systemName: "star.circle.fill")
                                                    .font(.system(size: 24))
                                                    .scaleEffect(animate ? 1.1 : 1.0)
                                                    .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animate)
                                                Text("Start Today's Challenge")
                                                    .fontWeight(.bold)
                                            }
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 58)
                                            .background(
                                                LinearGradient(
                                                    colors: [
                                                        DesignSystem.glowGreen,
                                                        DesignSystem.primaryGreen,
                                                        DesignSystem.secondaryGreen
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(29)
                                            .shadow(color: DesignSystem.glowGreen.opacity(0.5), radius: 20, x: 0, y: 5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 29)
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: [.white.opacity(0.5), .clear],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 1
                                                    )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: [glowGreen.opacity(0.8), glowGreen.opacity(0.2)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 1
                                                    )
                                            )
                                        }
                                    } else {
                                        VStack(alignment: .leading, spacing: 16) {
                                            VStack(spacing: 12) {
                                                HStack {
                                                    Image(systemName: "star.fill")
                                                        .foregroundColor(.yellow)
                                                        .font(.system(size: 24))
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(user.dailyChallenge)
                                                            .font(.headline)
                                                            .foregroundColor(.black)
                                                        
                                                        // Progress Bar
                                                        GeometryReader { geometry in
                                                            ZStack(alignment: .leading) {
                                                                Rectangle()
                                                                    .fill(Color.gray.opacity(0.2))
                                                                    .frame(height: 6)
                                                                    .cornerRadius(3)
                                                                
                                                                Rectangle()
                                                                    .fill(
                                                                        LinearGradient(
                                                                            colors: [primaryGreen, glowGreen],
                                                                            startPoint: .leading,
                                                                            endPoint: .trailing
                                                                        )
                                                                    )
                                                                    .frame(width: geometry.size.width * CGFloat(user.challengeProgress), height: 6)
                                                                    .cornerRadius(3)
                                                            }
                                                        }
                                                        .frame(height: 6)
                                                        
                                                        Text("\(Int(user.challengeProgress * 100))% Complete")
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                                
                                                // Challenge Steps
                                                VStack(alignment: .leading, spacing: 8) {
                                                    ForEach(user.challengeSteps.indices, id: \.self) { index in
                                                        Button(action: {
                                                            user.toggleChallengeStep(index)
                                                        }) {
                                                            HStack {
                                                                Image(systemName: user.challengeSteps[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                                                    .foregroundColor(user.challengeSteps[index].isCompleted ? .green : .gray)
                                                                Text(user.challengeSteps[index].description)
                                                                    .foregroundColor(.primary)
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                }
                                                .padding(.top, 8)
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal)
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(15)

                                            Button(action: {
                                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                    showReward = true
                                                    lastReward = "+100 XP"
                                                    user.completeChallenge()
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 20))
                                                    Text("Complete Challenge")
                                                        .fontWeight(.semibold)
                                                }
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 50)
                                                .background(
                                                    LinearGradient(
                                                        colors: [primaryGreen, secondaryGreen],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .cornerRadius(25)
                                                .shadow(color: glowGreen.opacity(0.5), radius: 15)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 25)
                                                        .stroke(
                                                            LinearGradient(
                                                                colors: [glowGreen.opacity(0.8), glowGreen.opacity(0.2)],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            lineWidth: 1
                                                        )
                                                )
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .background(
                                    LinearGradient(
                                        colors: [cardBackground, Color.green.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(24)
                                .shadow(color: glowGreen.opacity(0.3), radius: 20, x: 0, y: 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            LinearGradient(
                                                colors: [glowGreen.opacity(0.5), glowGreen.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .padding(.horizontal, 16)
                                .sheet(isPresented: $showChallengePicker) {
                                    ChallengePicker(user: $user, isPresented: $showChallengePicker)
                                }

                                Spacer()
                                    .frame(height: 30)

                                // Quick Actions
                                VStack(spacing: 16) {
                                    QuickActionCard(
                                        title: "Learn",
                                        subtitle: "Start your journey",
                                        icon: "brain.head.profile",
                                        reward: "+50 XP",
                                        action: { showFinanceLesson = true }
                                    )
                                    .onTapGesture {
                                        showFinanceLesson = true
                                    }
                                    .sheet(isPresented: $showFinanceLesson) {
                                        LearnView(user: $user)
                                    }

                                    NavigationLink(destination: ProgressView(user: $user)) {
                                        QuickActionCard(
                                            title: "Progress Dashboard",
                                            subtitle: "Track your achievements and streaks",
                                            icon: "chart.line.uptrend.xyaxis",
                                            reward: "View Stats"
                                        )
                                    }
                                }
                                .padding(.horizontal)

                                Spacer()
                            }
                            .padding(.top, 20)
                        }
                    }

                    Spacer()

                    // Navigation Bar
                    CustomTabBar(selectedTab: $selectedTab, showFinanceLesson: $showFinanceLesson, user: $user)
                        .background(Color.white)
                }
            }
        }
        .preferredColorScheme(colorScheme)
        .onChange(of: colorScheme) { newValue in
            savedColorScheme = newValue == .light ? "light" : "dark"
        }
    }
}

struct LevelCircle: View {
    let level: Int
    let xp: Int
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            Text("LV \(level)")
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(.green)
            Text("\(xp)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.green.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.green.opacity(0.2), radius: 6, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.1), lineWidth: 1)
                )
        )
        .onAppear {
            isAnimating = true
        }
    }
}

struct StreakBadge: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 20))
                .foregroundColor(.orange)
            Text("\(streak)")
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
}

struct FeatureBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    @State private var isAnimating = false
    @State private var isGlowing = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(isGlowing ? 0.6 : 0.3), lineWidth: 2)
                            .scaleEffect(isGlowing ? 1.1 : 1.0)
                    )

                Image(systemName: icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(color)
                    .scaleEffect(isAnimating ? 1.15 : 1.0)
                    .rotationEffect(.degrees(isAnimating ? 8 : -8))
                    .shadow(color: color.opacity(0.5), radius: 5)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                    isGlowing = true
                }
            }

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(width: 100)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            isAnimating = true
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let reward: String
    let glowGreen = Color(red: 0.0, green: 0.8, blue: 0.4)
    var action: (() -> Void)? = nil
    @State private var isPressed = false
    @State private var isHovered = false
    @State private var isGlowing = false
    @State private var iconRotation: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [glowGreen.opacity(0.3), glowGreen.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .blur(radius: 5)

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                        .shadow(color: glowGreen, radius: 8, x: 0, y: 0)
                        .scaleEffect(isPressed ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPressed)
                }
                Spacer()
            }

            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.black)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)

            Text(reward)
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: [glowGreen.opacity(0.3), glowGreen.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [glowGreen.opacity(0.6), glowGreen.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: glowGreen.opacity(0.3), radius: 5)
                .foregroundColor(.green)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                Color.white
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
                            colors: [glowGreen.opacity(0.7), glowGreen.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .cornerRadius(25)
        .shadow(color: glowGreen.opacity(0.2), radius: 20, x: 0, y: 10)
        .shadow(color: glowGreen.opacity(0.1), radius: 40, x: 0, y: 20)
        .onAppear { isPressed = true }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showFinanceLesson: Bool
    @Binding var user: User

    var body: some View {
        HStack {
            Button(action: { selectedTab = 0 }) {
                Image(systemName: "house.fill")
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == 0 ? .green : .gray)
                    .shadow(color: selectedTab == 0 ? Color.green.opacity(0.5) : Color.clear, radius: 5)
                    .frame(maxWidth: .infinity)
            }

            Button(action: { showFinanceLesson = true }) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == 1 ? .green : .gray)
                    .frame(maxWidth: .infinity)
            }

            Button(action: { selectedTab = 2 }) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == 2 ? .green : .gray)
                    .frame(maxWidth: .infinity)
            }

            Button(action: { selectedTab = 3 }) {
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == 3 ? .green : .gray)
                    .frame(maxWidth: .infinity)
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedTab == 3 },
                set: { if !$0 { selectedTab = 0 } }
            )) {
                ProgressView(user: $user)
            }

            Button(action: { selectedTab = 4 }) {
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == 4 ? .green : .gray)
                    .frame(maxWidth: .infinity)
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedTab == 4 },
                set: { if !$0 { selectedTab = 0 } }
            )) {
                ProfileView(user: $user)
            }
        }
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [.white, Color.green.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [Color.green.opacity(0.4), Color.green.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .cornerRadius(25)
        .shadow(color: Color.green.opacity(0.2), radius: 15)
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
}

struct User: Identifiable {
    let id = UUID()
    var level: Int
    var xp: Int
    var streak: Int
    var notificationManager = NotificationManager.shared
    var lastActiveDate: Date?
    var dailyChallenge: String = ""
    var challengeProgress: Double = 0.0
    var challengeSteps: [ChallengeStep] = [
        ChallengeStep(description: "Start the challenge"),
        ChallengeStep(description: "Make progress"),
        ChallengeStep(description: "Complete the task")
    ]
    
    mutating func toggleChallengeStep(_ index: Int) {
        guard index < challengeSteps.count else { return }
        challengeSteps[index].isCompleted.toggle()
        challengeProgress = Double(challengeSteps.filter { $0.isCompleted }.count) / Double(challengeSteps.count)
    }
    var achievements: [Achievement] = [
        Achievement(title: "First Goal", description: "Set your first financial goal", icon: "flag.fill", unlocked: true),
        Achievement(title: "Streak Master", description: "Maintain a 7-day streak", icon: "flame.fill", unlocked: false),
        Achievement(title: "Saver", description: "Save $100", icon: "dollarsign.circle.fill", unlocked: false)
    ]
    var activeGoals: [UserGoal] = []

    mutating func setChallenge(_ challenge: String) {
        dailyChallenge = challenge
    }

    mutating func completeChallenge() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            xp += 100
            if xp >= 200 {
                level += 1
                xp = xp - 200
                generator.notificationOccurred(.warning)
            }
        }
        updateStreak()
        challengeSteps = challengeSteps.map { step in
            var newStep = step
            newStep.isCompleted = false
            return newStep
        }
        challengeProgress = 0.0
        dailyChallenge = ""
    }

    private mutating func updateStreak() {
        let calendar = Calendar.current
        let today = Date()

        if let lastActive = lastActiveDate {
            let daysSinceLastActive = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastActive), to: calendar.startOfDay(for: today)).day ?? 0

            if daysSinceLastActive == 1 {
                // User was active yesterday, increment streak
                streak += 1
            } else if daysSinceLastActive > 1 {
                // User missed a day, reset streak
                streak = 1
            }
            // If daysSinceLastActive == 0, user already active today, don't change streak
        } else {
            // First time user is active
            streak = 1
        }

        lastActiveDate = today
        UserDefaults.standard.set(lastActiveDate, forKey: "lastActiveDate")
        UserDefaults.standard.set(streak, forKey: "userStreak")
    }

    static func loadSavedStreak() -> (Int, Date?) {
        let savedStreak = UserDefaults.standard.integer(forKey: "userStreak")
        let savedDate = UserDefaults.standard.object(forKey: "lastActiveDate") as? Date
        return (savedStreak == 0 ? 1 : savedStreak, savedDate)
    }

    static func loadSavedGoals() -> [UserGoal] {
        if let data = UserDefaults.standard.data(forKey: "userGoals"),
           let decoded = try? JSONDecoder().decode([UserGoal].self, from: data) {
            return decoded
        }
        return []
    }

    func saveGoals() {
        if let encoded = try? JSONEncoder().encode(activeGoals) {
            UserDefaults.standard.set(encoded, forKey: "userGoals")
        }
    }
}

struct ChallengePicker: View {
    @Binding var user: User
    @Binding var isPresented: Bool
    @State private var selectedCategory: ChallengeCategory = .saving

    let challenges: [Challenge] = [
        // Moneybot Saving Challenges 💰
        Challenge(title: "Save $5 💵", description: "Put $5 into your savings account", category: .saving, xpReward: 50, difficultyLevel: .easy),
        Challenge(title: "No-Spend Day 🚫", description: "Go one full day without spending any money", category: .saving, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Save Change 💳", description: "Put all your loose change into savings", category: .saving, xpReward: 50, difficultyLevel: .easy),
        Challenge(title: "Emergency Fund 🛡️", description: "Start an emergency fund with any amount", category: .saving, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Weekly Savings Goal 🎯", description: "Set aside 10% of your weekly income", category: .saving, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Save $10 💵", description: "Add $10 to your savings account", category: .saving, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Save Bonus 💸", description: "Save any unexpected income", category: .saving, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Save on Groceries 🛒", description: "Reduce grocery bill by $10", category: .saving, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Save on Utilities ⚡️", description: "Reduce utility bill by $5", category: .saving, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Save on Transport 🚌", description: "Use public transport instead of driving for a week", category: .saving, xpReward: 100, difficultyLevel: .medium),

        // Moneybot Investing Challenges 📈
        Challenge(title: "Research ETFs 📊", description: "Learn about ETF investing for 15 minutes", category: .investing, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Stock Analysis 📉", description: "Research one company's financial statements", category: .investing, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Investment Terms 📚", description: "Learn 5 new investment terms", category: .investing, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Portfolio Review 📋", description: "Review and rebalance your investments", category: .investing, xpReward: 200, difficultyLevel: .hard),
        Challenge(title: "Dividend Research 💸", description: "Research dividend-paying stocks", category: .investing, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Investment Books 📚", description: "Read a chapter from an investment book", category: .investing, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Investment Podcast 🎧", description: "Listen to an investing podcast", category: .investing, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Investment App 📱", description: "Try a new investment app", category: .investing, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Investment Webinar 💻", description: "Attend a free investment webinar", category: .investing, xpReward: 150, difficultyLevel: .medium),
        Challenge(title: "Investment Goals 🎯", description: "Set a new investment goal", category: .investing, xpReward: 125, difficultyLevel: .medium),

        // Moneybot Budgeting Challenges 📊
        Challenge(title: "Track Expenses 📝", description: "Log all your expenses for the day", category: .budgeting, xpReward: 75, difficultyLevel: .medium),
        Challenge(title: "Create Budget 🏗️", description: "Set up a basic monthly budget", category: .budgeting, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Expense Audit 🔍", description: "Review last month's expenses", category: .budgeting, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Cut One Cost ✂️", description: "Find one subscription to cancel", category: .budgeting, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Bill Negotiation 📞", description: "Try to negotiate one monthly bill", category: .budgeting, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Budget Review 📋", description: "Review and adjust your budget", category: .budgeting, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Daily Budget 📅", description: "Set a daily spending limit", category: .budgeting, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Budget for Fun 🎈", description: "Allocate budget for entertainment", category: .budgeting, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Budget for Gifts 🎁", description: "Plan a budget for upcoming gifts", category: .budgeting, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Budget for Travel 🌴", description: "Create a travel budget", category: .budgeting, xpReward: 150, difficultyLevel: .hard),

        // Moneybot Learning Challenges 📚
        Challenge(title: "Read Article 📰", description: "Read a financial article", category: .learning, xpReward: 50, difficultyLevel: .easy),
        Challenge(title: "Watch Tutorial 🎬", description: "Watch an investing tutorial", category: .learning, xpReward: 75, difficultyLevel: .medium),
        Challenge(title: "Finance Book 📚", description: "Read one chapter of a finance book", category: .learning, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Market Research 📈", description: "Study market trends for 30 minutes", category: .learning, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Term Research 🔍", description: "Learn 3 new financial terms", category: .learning, xpReward: 50, difficultyLevel: .easy),
        Challenge(title: "Financial News 📰", description: "Read today's financial news", category: .learning, xpReward: 75, difficultyLevel: .medium),
        Challenge(title: "Financial Documentary 🎬", description: "Watch a financial documentary", category: .learning, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Financial Blog 📝", description: "Read a financial blog post", category: .learning, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Financial Course 🎓", description: "Enroll in a free financial course", category: .learning, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Financial Quiz 🎯", description: "Take a financial literacy quiz", category: .learning, xpReward: 100, difficultyLevel: .medium),

        // Moneybot Crypto Challenges 🔒
        Challenge(title: "Blockchain Basics 🔗", description: "Learn how blockchain works", category: .crypto, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Crypto Research 🔍", description: "Research one cryptocurrency", category: .crypto, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "DeFi Learning 🌐", description: "Learn about DeFi protocols", category: .crypto, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Wallet Setup 👛", description: "Set up a crypto wallet", category: .crypto, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "NFT Study 🎨", description: "Research NFT marketplaces", category: .crypto, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Crypto News 📰", description: "Read today's crypto news", category: .crypto, xpReward: 75, difficultyLevel: .medium),
        Challenge(title: "Crypto Podcast 🎧", description: "Listen to a crypto podcast", category: .crypto, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Crypto Course 🎓", description: "Enroll in a free crypto course", category: .crypto, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Crypto Community 👥", description: "Join a crypto community forum", category: .crypto, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Crypto Security 🔒", description: "Learn about crypto security practices", category: .crypto, xpReward: 125, difficultyLevel: .medium),

        // Moneybot Side Hustle Challenges 🚀
        Challenge(title: "Skill Assessment 🎯", description: "List your marketable skills", category: .sideHustle, xpReward: 50, difficultyLevel: .easy),
        Challenge(title: "Gig Research 🔍", description: "Research online gig opportunities", category: .sideHustle, xpReward: 75, difficultyLevel: .medium),
        Challenge(title: "Portfolio Start 📂", description: "Start a work portfolio", category: .sideHustle, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Business Plan 📝", description: "Outline a simple business plan", category: .sideHustle, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Market Research 🔍", description: "Research potential customers", category: .sideHustle, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Freelance Platform 💻", description: "Sign up on a freelance platform", category: .sideHustle, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Side Hustle Goals 🎯", description: "Set income goals for your side hustle", category: .sideHustle, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Networking 👥", description: "Attend a networking event", category: .sideHustle, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Skill Development 📚", description: "Learn a new skill related to your side hustle", category: .sideHustle, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Marketing Plan 📈", description: "Create a marketing plan for your side hustle", category: .sideHustle, xpReward: 125, difficultyLevel: .medium),

        // Moneybot Tech Challenges 💻
        Challenge(title: "App Compare 📱", description: "Compare 3 finance apps", category: .tech, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "AutoPay Setup 💳", description: "Set up automatic bill payments", category: .tech, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Digital Security 🔒", description: "Review financial account security", category: .tech, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Bank App Setup 🏦", description: "Set up mobile banking", category: .tech, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Budget App 💰", description: "Try a new budgeting app", category: .tech, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Finance Tracker 📊", description: "Use a finance tracking app", category: .tech, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Investment App 📈", description: "Try a new investment app", category: .tech, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Crypto App 🔒", description: "Try a new crypto trading app", category: .tech, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Financial News App 📰", description: "Use a financial news app", category: .tech, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Tax App 📋", description: "Try a tax management app", category: .tech, xpReward: 150, difficultyLevel: .hard),

        // Moneybot Social Challenges 👥
        // LEVEL 1: FINANCIAL FOUNDATIONS
        Challenge(title: "Money Mindset Check 🧠", description: "Quiz a friend on financial myths vs facts", category: .social, xpReward: 50, difficultyLevel: .easy),
        Challenge(title: "Budget Buddy System 📱", description: "Help someone track expenses for a week", category: .social, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Bank Account Boss 🏦", description: "Compare different bank accounts with friends", category: .social, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Financial Goal Share 🎯", description: "Share your financial goals with a friend", category: .social, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Savings Challenge 💵", description: "Challenge a friend to save $10", category: .social, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Investment Chat 📈", description: "Discuss investment ideas with a friend", category: .social, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Budget Review 📋", description: "Review a friend's budget", category: .social, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Financial Book Club 📚", description: "Start a financial book club", category: .social, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Money Quiz Night 🎯", description: "Host a financial quiz night", category: .social, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Financial Planning Session 📅", description: "Plan finances with a friend", category: .social, xpReward: 150, difficultyLevel: .hard),

        // LEVEL 2: SAVING & PLANNING
        Challenge(title: "Emergency Fund Squad 🛡️", description: "Start emergency fund challenge with friends", category: .social, xpReward: 150, difficultyLevel: .medium),
        Challenge(title: "Future Rich Check 🕰️", description: "Calculate retirement needs with study group", category: .social, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Spend Analysis Team 🔍", description: "Review each other's spending patterns", category: .social, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Savings Goal Group 🎯", description: "Set savings goals with friends", category: .social, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Investment Club 📈", description: "Start an investment club", category: .social, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Budget Challenge 📋", description: "Challenge friends to stick to a budget", category: .social, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Financial Workshop 🎓", description: "Host a financial workshop", category: .social, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Money Saving Tips 💡", description: "Share money-saving tips with friends", category: .social, xpReward: 75, difficultyLevel: .easy),
        Challenge(title: "Investment Seminar 📚", description: "Attend an investment seminar with friends", category: .social, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Financial Planning Group 📅", description: "Plan finances with a group", category: .social, xpReward: 150, difficultyLevel: .hard),

        // LEVEL 3: INVESTING FUNDAMENTALS
        Challenge(title: "Stock Market Crew 📈", description: "Start investment learning circle", category: .social, xpReward: 200, difficultyLevel: .hard),
        Challenge(title: "ETF Research Team 📊", description: "Group study popular ETFs and fees", category: .social, xpReward: 175, difficultyLevel: .hard),
        Challenge(title: "Index vs Active Debate 🎯", description: "Host investing strategy discussion", category: .social, xpReward: 150, difficultyLevel: .medium),
        Challenge(title: "Investment Club Meeting 📈", description: "Host an investment club meeting", category: .social, xpReward: 175, difficultyLevel: .hard),
        Challenge(title: "Stock Picking Contest 🏆", description: "Compete with friends to pick the best stocks", category: .social, xpReward: 200, difficultyLevel: .hard),
        Challenge(title: "Investment Book Club 📚", description: "Start an investment book club", category: .social, xpReward: 150, difficultyLevel: .medium),
        Challenge(title: "Financial News Discussion 📰", description: "Discuss financial news with friends", category: .social, xpReward: 100, difficultyLevel: .medium),
        Challenge(title: "Investment Goals Group 🎯", description: "Set investment goals with friends", category: .social, xpReward: 150, difficultyLevel: .hard),
        Challenge(title: "Dividend Investing Club 💸", description: "Start a dividend investing club", category: .social, xpReward: 175, difficultyLevel: .hard),
        Challenge(title: "Financial Analysis Group 📊", description: "Analyze financial statements with friends", category: .social, xpReward: 200, difficultyLevel: .hard),

        // LEVEL 4: CREDIT MASTERY
        Challenge(title: "Credit Score League 💳", description: "Share credit-building strategies", category: .social, xpReward: 150, difficultyLevel: .medium),
        Challenge(title: "Debt Destroyer Squad 💪", description: "Create group debt payoff strategy", category: .social, xpReward: 200, difficultyLevel: .hard),
        Challenge(title: "Interest Rate Warriors ⚔️", description: "Compare loan terms with friends", category: .social, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Credit Report Review 📋", description: "Review credit reports with friends", category: .social, xpReward: 150, difficultyLevel: .medium),
        Challenge(title: "Credit Card Rewards 💳", description: "Discuss credit card rewards with friends", category: .social, xpReward: 100, difficultyLevel: .easy),
        Challenge(title: "Debt Consolidation 📉", description: "Discuss debt consolidation strategies", category: .social, xpReward: 150, difficultyLevel: .medium),
        Challenge(title: "Credit Score Challenge 🎯", description: "Challenge friends to improve credit scores", category: .social, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Loan Application Tips 📝", description: "Share loan application tips", category: .social, xpReward: 100, difficultyLevel: .easy),
        Challenge(title: "Credit Utilization 📊", description: "Discuss credit utilization strategies", category: .social, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Credit Counseling 👥", description: "Attend a credit counseling session with friends", category: .social, xpReward: 150, difficultyLevel: .hard),

        // LEVEL 5: INCOME EXPANSION
        Challenge(title: "Side Hustle Incubator 🚀", description: "Brainstorm income ideas with group", category: .social, xpReward: 175, difficultyLevel: .hard),
        Challenge(title: "Skill Stack Society 📚", description: "Share valuable career skills", category: .social, xpReward: 150, difficultyLevel: .medium),
        Challenge(title: "Passive Income Guild ⚡️", description: "Research passive income as team", category: .social, xpReward: 225, difficultyLevel: .hard),
        Challenge(title: "Income Goal Group 🎯", description: "Set income goals with friends", category: .social, xpReward: 150, difficultyLevel: .medium),
        Challenge(title: "Freelance Club 💻", description: "Start a freelance club", category: .social, xpReward: 175, difficultyLevel: .hard),
        Challenge(title: "Networking Event 👥", description: "Attend a networking event with friends", category: .social, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Business Idea Brainstorm 💡", description: "Brainstorm business ideas with friends", category: .social, xpReward: 150, difficultyLevel: .medium),
        Challenge(title: "Marketing Strategies 📈", description: "Discuss marketing strategies with friends", category: .social, xpReward: 125, difficultyLevel: .medium),
        Challenge(title: "Investment Income 💸", description: "Discuss investment income strategies", category: .social, xpReward: 150, difficultyLevel: .medium),
        Challenge(title: "Career Development 🎓", description: "Discuss career development strategies", category: .social, xpReward: 125, difficultyLevel: .medium),

        // LEVEL 6: ADVANCED MOVES
        Challenge(title: "Tax Tactics Team 📋", description: "Learn tax strategies together", category: .social, xpReward: 250, difficultyLevel: .hard),
        Challenge(title: "Real Estate Roundtable 🏠", description: "Study property investment basics", category: .social, xpReward: 200, difficultyLevel: .hard),
        Challenge(title: "Portfolio Pro Team 💼", description: "Create mock investment portfolios", category: .social, xpReward: 225, difficultyLevel: .hard),
        Challenge(title: "Retirement Planning 🕰️", description: "Plan for retirement with friends", category: .social, xpReward: 250, difficultyLevel: .hard),
        Challenge(title: "Estate Planning 📜", description: "Discuss estate planning strategies", category: .social, xpReward: 225, difficultyLevel: .hard),
        Challenge(title: "Financial Advisor Meeting 👥", description: "Meet with a financial advisor", category: .social, xpReward: 200, difficultyLevel: .hard),
        Challenge(title: "Investment Property 🏠", description: "Discuss investment property strategies", category: .social, xpReward: 225, difficultyLevel: .hard),
        Challenge(title: "Advanced Tax Strategies 📋", description: "Learn advanced tax strategies", category: .social, xpReward: 250, difficultyLevel: .hard),
        Challenge(title: "Wealth Management 💼", description: "Discuss wealth management strategies", category: .social, xpReward: 225, difficultyLevel: .hard),
        Challenge(title: "Financial Independence 🏆", description: "Plan for financial independence with friends", category: .social, xpReward: 250, difficultyLevel: .hard),

        // SPECIAL CHALLENGES
        Challenge(title: "Money Mentor Elite 👑", description: "Help 5 friends with financial goals", category: .social, xpReward: 300, difficultyLevel: .hard),
        Challenge(title: "Financial Freedom Club 🎮", description: "Start weekly money mastermind", category: .social, xpReward: 275, difficultyLevel: .hard)

    ]

    var filteredChallenges: [Challenge] {
        challenges.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(ChallengeCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding()
                }

                // Challenges List
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredChallenges) { challenge in
                            ChallengeCard(challenge: challenge) {
                                user.setChallenge(challenge.title)
                                isPresented = false
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Daily Challenges")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
            .background(Color(UIColor.systemBackground))
        }
    }
}

struct CategoryButton: View {
    let category: ChallengeCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.green : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    let action: () -> Void
    @State private var showDetails = false
    @State private var animate = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showDetails.toggle()
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(challenge.title)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.primary)
                        
                        if showDetails {
                            Text(challenge.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                                .transition(.opacity)
                        }
                    }
                    
                    Spacer()
                    
                    Text("+\(challenge.xpReward) XP")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                )
                        )
                }

                HStack(spacing: 8) {
                    Label(challenge.category.rawValue, systemImage: "tag.fill")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(10)

                    Label(
                        challenge.difficultyLevel.rawValue,
                        systemImage: challenge.difficultyLevel == .easy ? "tortoise.fill" :
                                   challenge.difficultyLevel == .medium ? "hare.fill" : "bolt.fill"
                    )
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        challenge.difficultyLevel == .easy ? Color.green.opacity(0.1) :
                        challenge.difficultyLevel == .medium ? Color.orange.opacity(0.1) :
                        Color.red.opacity(0.1)
                    )
                    .foregroundColor(
                        challenge.difficultyLevel == .easy ? .green :
                        challenge.difficultyLevel == .medium ? .orange :
                        .red
                    )
                    .cornerRadius(10)
                }

                if showDetails {
                    Button(action: action) {
                        Text("Accept Challenge")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [DesignSystem.primaryGreen, DesignSystem.secondaryGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                    }
                    .padding(.top, 8)
                    .transition(.opacity)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: showDetails ? 15 : 10,
                        x: 0,
                        y: showDetails ? 10 : 5
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                DesignSystem.glowGreen.opacity(showDetails ? 0.3 : 0.1),
                                DesignSystem.glowGreen.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    Color.white.opacity(0.2),
                                    .clear
                                ],
                                startPoint: UnitPoint(x: 0, y: 0.4),
                                endPoint: UnitPoint(x: 1, y: 0.6)
                            )
                        )
                        .rotationEffect(.degrees(15))
                        .offset(x: animate ? geometry.size.width : -geometry.size.width)
                        .animation(
                            Animation.linear(duration: 2)
                                .repeatForever(autoreverses: false)
                                .delay(Double.random(in: 0...2)),
                            value: animate
                        )
                }
            )
            .onAppear {
                animate = true
            }
        }
        .buttonStyle(PlainButtonStyle())
        .challengeCardStyle()
    }
}

#Preview {
    ContentView()
}