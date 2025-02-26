
import SwiftUI

struct OnboardingView: View {
    @Binding var user: User
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 0
    @State private var goalTitle = ""
    @State private var goalAmount = ""
    @State private var selectedPeriod: ProgressView.GoalPeriod = .month
    @State private var targetDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
    @State private var animate = false
    @State private var showGlow = false
    
    let steps = [
        OnboardingStep(
            title: "Welcome to Moneybot! 🤖",
            subtitle: "Your AI-powered financial companion",
            icon: "sparkles"
        ),
        OnboardingStep(
            title: "Level Up Your Finances 🎯",
            subtitle: "Complete daily challenges to earn XP and unlock achievements",
            icon: "trophy.fill"
        ),
        OnboardingStep(
            title: "Track Your Journey 📈",
            subtitle: "Watch your progress and celebrate milestones",
            icon: "chart.line.uptrend.xyaxis.circle.fill"
        ),
        OnboardingStep(
            title: "Set Your First Goal! 🎉",
            subtitle: "Let's begin your financial adventure",
            icon: "flag.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated background
            DesignSystem.Effects.glowBackground()
                .opacity(showGlow ? 0.5 : 0.3)
                .animation(.easeInOut(duration: 2).repeatForever(), value: showGlow)
            
            VStack(spacing: 30) {
                if currentStep < 3 {
                    Spacer()
                    
                    // Animated logo
                    Image("new-moneybot-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .shadow(color: DesignSystem.glowGreen.opacity(0.5), radius: animate ? 15 : 5)
                        .scaleEffect(animate ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(), value: animate)
                    
                    // Step content
                    VStack(spacing: 16) {
                        Image(systemName: steps[currentStep].icon)
                            .font(.system(size: 40))
                            .foregroundColor(DesignSystem.primaryGreen)
                            .rotationEffect(.degrees(animate ? 8 : -8))
                            .animation(.easeInOut(duration: 1.5).repeatForever(), value: animate)
                        
                        Text(steps[currentStep].title)
                            .font(DesignSystem.Typography.gameTitle)
                            .multilineTextAlignment(.center)
                        
                        Text(steps[currentStep].subtitle)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: DesignSystem.glowGreen.opacity(0.3), radius: 20)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    colors: [DesignSystem.glowGreen.opacity(0.5), DesignSystem.glowGreen.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    
                    Spacer()
                    
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { step in
                            Circle()
                                .fill(step == currentStep ? DesignSystem.primaryGreen : Color.gray.opacity(0.3))
                                .frame(width: 10, height: 10)
                                .scaleEffect(step == currentStep ? 1.2 : 1.0)
                                .animation(.spring(), value: currentStep)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Navigation buttons
                    HStack(spacing: 20) {
                        if currentStep > 0 {
                            Button(action: { currentStep -= 1 }) {
                                Text("Back")
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.primaryGreen)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 15)
                                    .background(Color.white)
                                    .cornerRadius(25)
                                    .shadow(color: DesignSystem.glowGreen.opacity(0.2), radius: 10)
                            }
                        }
                        
                        Button(action: { currentStep += 1 }) {
                            Text(currentStep == 2 ? "Let's Go!" : "Next")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background(
                                    LinearGradient(
                                        colors: [DesignSystem.primaryGreen, DesignSystem.secondaryGreen],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: DesignSystem.glowGreen.opacity(0.3), radius: 10)
                        }
                    }
                    .padding(.bottom, 40)
                    
                } else {
                    GoalSetupView(
                        goalTitle: $goalTitle,
                        goalAmount: $goalAmount,
                        selectedPeriod: $selectedPeriod,
                        targetDate: $targetDate,
                        onComplete: {
                            let newGoal = UserGoal(
                                title: goalTitle,
                                targetAmount: Double(goalAmount) ?? 0,
                                period: selectedPeriod,
                                currentAmount: 0,
                                targetCompletionDate: targetDate
                            )
                            user.activeGoals.append(newGoal)
                            user.saveGoals()
                            dismiss()
                        }
                    )
                }
            }
        }
        .onAppear {
            animate = true
            showGlow = true
        }
    }
}

struct OnboardingStep {
    let title: String
    let subtitle: String
    let icon: String
}

struct GoalSetupView: View {
    @Binding var goalTitle: String
    @Binding var goalAmount: String
    @Binding var selectedPeriod: ProgressView.GoalPeriod
    @Binding var targetDate: Date
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Set Your First Goal")
                .font(DesignSystem.Typography.gameTitle)
                .foregroundColor(DesignSystem.primaryGreen)
            
            VStack(spacing: 16) {
                TextField("Goal Title", text: $goalTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Target Amount ($)", text: $goalAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(ProgressView.GoalPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                    .padding(.horizontal)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: DesignSystem.glowGreen.opacity(0.1), radius: 10)
            
            Button(action: onComplete) {
                Text("Start My Journey")
                    .font(DesignSystem.Typography.subtitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [DesignSystem.primaryGreen, DesignSystem.secondaryGreen],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: DesignSystem.glowGreen.opacity(0.3), radius: 10)
            }
            .padding(.horizontal)
            .disabled(goalTitle.isEmpty || goalAmount.isEmpty)
        }
        .padding()
    }
}
