import SwiftUI

struct ProgressView: View {
    @Binding var user: User
    @State private var selectedGoal: FinancialGoal?
    @State private var showingAddGoal = false
    @State private var customGoalAmount: String = ""
    @State private var customGoalTitle: String = ""
    @State private var customGoalPeriod: GoalPeriod = .week

    enum GoalPeriod: String, Codable, CaseIterable {
        case week = "Weekly"
        case month = "Monthly"
        case year = "Yearly"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header with Logo
                Image("new-moneybot-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 45)
                    .padding(.top)
                    .shadow(color: Color.green.opacity(0.5), radius: 10)
                    .overlay(
                        Image("new-moneybot-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .blur(radius: 4)
                            .opacity(0.3)
                    )

                // Stats Overview
                VStack(spacing: 12) {
                    Text("Your Progress")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    HStack(spacing: 20) {
                        StatCard(title: "Current Streak", value: "\(user.streak)", icon: "flame.fill", color: .orange)
                        StatCard(title: "Level", value: "\(user.level)", icon: "star.fill", color: .yellow)
                    }

                    StatCard(title: "XP Progress", value: "\(user.xp)/200", icon: "chart.bar.fill", color: .green)
                }
                .padding()

                // Achievements Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Achievements")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(user.achievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Active Goals Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Goals")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    if user.activeGoals.isEmpty {
                        Text("No active goals yet. Create one to get started!")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(user.activeGoals.indices, id: \.self) { index in
                            GoalProgressCard(goal: $user.activeGoals[index], user: $user)
                                .padding(.horizontal)
                        }
                    }
                }

                // Add New Goal Button
                Button(action: { showingAddGoal = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add New Goal")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green)
                    .cornerRadius(25)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showingAddGoal) {
            AddGoalSheet(user: $user, isPresented: $showingAddGoal)
        }
    }
}

struct AddGoalSheet: View {
    @Binding var user: User
    @Binding var isPresented: Bool
    @State private var goalTitle = ""
    @State private var goalAmount = ""
    @State private var selectedPeriod: ProgressView.GoalPeriod = .week
    @State private var targetDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var animateSuccess = false
    @State private var selectedEmoji = "🎯"

    let emojis = ["🎯", "💰", "🚀", "💎", "🏆", "✨", "💪", "🎮", "📱", "💻"]

    var isValidGoal: Bool {
        !goalTitle.isEmpty && Double(goalAmount) != nil
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Emoji Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(emojis, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 40))
                                .padding(10)
                                .background(selectedEmoji == emoji ? Color.green.opacity(0.2) : Color.clear)
                                .cornerRadius(15)
                                .scaleEffect(selectedEmoji == emoji ? 1.2 : 1.0)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedEmoji = emoji
                                    }
                                }
                        }
                    }
                    .padding()
                }

                VStack(spacing: 25) {
                    // Title Input
                    VStack(alignment: .leading) {
                        Text("What's your goal?")
                            .font(.headline)
                            .foregroundColor(.green)
                        TextField("Dream Gaming Setup, New iPhone, etc.", text: $goalTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }

                    // Amount Input
                    VStack(alignment: .leading) {
                        Text("How much do you need?")
                            .font(.headline)
                            .foregroundColor(.green)
                        HStack {
                            Text("$")
                                .font(.title2)
                            TextField("Amount", text: $goalAmount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                    }

                    // Period and Date Selector
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Timeline")
                                .font(.headline)
                                .foregroundColor(.green)
                            Picker("", selection: $selectedPeriod) {
                                ForEach(ProgressView.GoalPeriod.allCases, id: \.self) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                        }

                        VStack(alignment: .leading) {
                            Text("Target Completion Date")
                                .font(.headline)
                                .foregroundColor(.green)
                            DatePicker("", selection: $targetDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding()

                // Create Button
                Button(action: {
                    if isValidGoal {
                        withAnimation(.spring()) {
                            animateSuccess = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let newGoal = UserGoal(
                                title: "\(selectedEmoji) \(goalTitle)",
                                targetAmount: Double(goalAmount) ?? 0,
                                period: selectedPeriod,
                                currentAmount: 0,
                                targetCompletionDate: targetDate
                            )
                            user.activeGoals.append(newGoal)
                            user.saveGoals()
                            isPresented = false
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Goal")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isValidGoal ? Color.green : Color.gray)
                    .cornerRadius(25)
                    .scaleEffect(animateSuccess ? 1.1 : 1.0)
                }
                .padding(.horizontal)
                .disabled(!isValidGoal)
            }
            .navigationTitle("New Goal")
            .navigationBarItems(leading: Button("Cancel") { isPresented = false })
            .background(Color(UIColor.systemBackground))
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
                .rotation3DEffect(.degrees(isHovered ? 15 : 0), axis: (x: 1, y: 0, z: 0))
                .scaleEffect(isHovered ? 1.1 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isHovered)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        isHovered.toggle()
                    }
                }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.green.opacity(0.2), radius: 15, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.green.opacity(0.1), lineWidth: 1)
        )
    }
}

struct AchievementCard: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.system(size: 24))
                .foregroundColor(achievement.unlocked ? .green : .gray)

            Text(achievement.title)
                .font(.caption)
                .multilineTextAlignment(.center)

            if achievement.unlocked {
                Text("Unlocked!")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .frame(width: 90, height: 90)
        .padding(12)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
}

struct GoalProgressCard: View {
    @Binding var goal: UserGoal
    @Binding var user: User
    @State private var showingDetails = false
    @State private var isEditing = false
    @State private var newAmount = ""
    @State private var transactionNote = ""

    var progress: Double {
        min(goal.currentAmount / goal.targetAmount, 1.0)
    }

    var nextMilestone: Milestone? {
        goal.milestones.first { !$0.isCompleted }
    }

    var timeRemaining: String {
        let calendar = Calendar.current
        let components: Set<Calendar.Component> = [.day]
        let start = goal.startDate
        var targetDate: Date

        switch goal.period {
        case .week:
            targetDate = calendar.date(byAdding: .day, value: 7, to: start) ?? start
        case .month:
            targetDate = calendar.date(byAdding: .month, value: 1, to: start) ?? start
        case .year:
            targetDate = calendar.date(byAdding: .year, value: 1, to: start) ?? start
        }

        let remaining = calendar.dateComponents(components, from: Date(), to: targetDate)
        return "\(remaining.day ?? 0) days"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { showingDetails.toggle() }) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(goal.title)
                            .font(.headline)
                        Spacer()
                        Text(goal.period.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    ProgressBar(progress: progress)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("$\(Int(goal.currentAmount))")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("of $\(Int(goal.targetAmount))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(timeRemaining)
                                .font(.subheadline)
                                .foregroundColor(.green)
                            if let milestone = nextMilestone {
                                Text(milestone.title)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.white, Color.green.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .shadow(color: Color.green.opacity(0.2), radius: 15, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    LinearGradient(
                        colors: [Color.green.opacity(0.7), Color.green.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .sheet(isPresented: $showingDetails) {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        // 3D AR Visualization
                        ZStack {
                            // Floating particles effect
                            ForEach(0..<20) { i in
                                Circle()
                                    .fill(Color.green.opacity(0.2))
                                    .frame(width: CGFloat.random(in: 5...15))
                                    .offset(x: CGFloat.random(in: -100...100),
                                          y: CGFloat.random(in: -100...100))
                                    .blur(radius: 2)
                                    .animation(
                                        Animation.easeInOut(duration: Double.random(in: 2...4))
                                            .repeatForever()
                                            .delay(Double.random(in: 0...2)),
                                        value: UUID()
                                    )
                            }

                            // Holographic progress ring
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        colors: [.green, .blue, .purple, .green],
                                        center: .center,
                                        startAngle: .degrees(0),
                                        endAngle: .degrees(360)
                                    ),
                                    style: StrokeStyle(lineWidth: 25, lineCap: .round)
                                )
                                .frame(width: 200, height: 200)
                                .blur(radius: 1)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                        .frame(width: 200, height: 200)
                                        .blur(radius: 0.5)
                                )

                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    LinearGradient(
                                        colors: [.green, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(), value: progress)

                            VStack(spacing: 4) {
                                Text("$\(Int(goal.currentAmount))")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("of $\(Int(goal.targetAmount))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top)

                        // Smart Insights & AI Coach
                        VStack(spacing: 16) {
                            HStack {
                                Text("AI Financial Coach")
                                    .font(.headline)
                                Image(systemName: "brain.head.profile")
                                    .foregroundColor(.purple)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            // Dynamic AI recommendations
                            AIRecommendationCard(goal: goal)

                            // Smart spending patterns
                            SpendingPatternView(transactions: goal.transactions)

                            // Gamified achievements
                            AchievementProgressView(goal: goal)

                            HStack(spacing: 20) {
                                InsightCard(
                                    title: "Avg. Contribution",
                                    value: "$\(Int(goal.averageContribution))",
                                    icon: "chart.bar.fill",
                                    color: .blue
                                )

                                InsightCard(
                                    title: "Est. Completion",
                                    value: goal.estimatedCompletionDate.formatted(date: .abbreviated, time: .omitted),
                                    icon: "calendar",
                                    color: .purple
                                )
                            }

                            if goal.progressRate > 0 {
                                Text(goal.progressRate > 1 ? "You're ahead of schedule! 🚀" : "Keep pushing! 💪")
                                    .font(.subheadline)
                                    .foregroundColor(goal.progressRate > 1 ? .green : .orange)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 10)

                        // Add Progress Card
                        VStack(spacing: 16) {
                            Text("Add Progress")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 12) {
                                TextField("$", text: $newAmount)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 100)

                                TextField("What's this for?", text: $transactionNote)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                Button(action: {
                                    if let amount = Double(newAmount) {
                                        withAnimation(.spring()) {
                                            let transaction = Transaction(amount: amount, date: Date(), note: transactionNote)
                                            goal.transactions.append(transaction)
                                            goal.currentAmount += amount

                                            // Update milestones with animation
                                            for index in goal.milestones.indices {
                                                if goal.currentAmount >= goal.milestones[index].targetAmount {
                                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                                        goal.milestones[index].isCompleted = true
                                                    }
                                                }
                                            }

                                            newAmount = ""
                                            transactionNote = ""
                                            user.saveGoals()
                                        }
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.green)
                                }
                                .disabled(newAmount.isEmpty)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 10)

                        // Milestones Journey
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Achievement Journey")
                                .font(.headline)

                            ForEach(goal.milestones) { milestone in
                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(milestone.isCompleted ? Color.green : Color.gray.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Image(systemName: milestone.isCompleted ? "checkmark" : "lock")
                                                .foregroundColor(.white)
                                        )
                                        .shadow(color: milestone.isCompleted ? Color.green.opacity(0.3) : .clear, radius: 5)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(milestone.title)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text("$\(Int(milestone.targetAmount))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    if milestone.isCompleted {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .shadow(color: .yellow.opacity(0.3), radius: 5)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.05), radius: 5)
                            }
                        }
                        .padding()

                        // Recent Activity
                        if !goal.transactions.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Activity")
                                    .font(.headline)

                                ForEach(goal.transactions.prefix(5).reversed()) { transaction in
                                    HStack(spacing: 16) {
                                        Circle()
                                            .fill(Color.green.opacity(0.1))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "arrow.up.circle.fill")
                                                    .foregroundColor(.green)
                                            )

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("+$\(Int(transaction.amount))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            Text(transaction.note)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }

                                        Spacer()

                                        Text(transaction.date, style: .date)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                .navigationTitle(goal.title)
                .navigationBarItems(
                    leading: Menu {
                        Button(action: {
                            showingDetails = false
                            if let index = user.activeGoals.firstIndex(where: { $0.id == goal.id }) {
                                user.activeGoals.remove(at: index)
                            }
                        }) {
                            Label("Delete Goal", systemImage: "trash")
                                .foregroundColor(.red)
                        }

                        Button(action: {
                            isEditing.toggle()
                        }) {
                            Label("Edit Goal", systemImage: "pencil")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    },
                    trailing: Button("Done") { showingDetails = false }
                )
                .sheet(isPresented: $isEditing) {
                    EditGoalSheet(goal: $goal)
                }
            }
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                    .cornerRadius(6)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 12)
                    .cornerRadius(6)
                    .shadow(color: Color.green.opacity(0.5), radius: 4)
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 20, height: 12)
                            .blur(radius: 3)
                            .offset(x: isAnimating ? geometry.size.width : -20)
                    )
            }
        }
        .frame(height: 12)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 16, weight: .bold))

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
struct EditGoalSheet: View {
    @Binding var goal: UserGoal
    @Environment(\.dismiss) var dismiss
    @State private var editedTitle: String
    @State private var editedAmount: String
    @State private var editedDate: Date

    init(goal: Binding<UserGoal>) {
        _goal = goal
        _editedTitle = State(initialValue: goal.wrappedValue.title)
        _editedAmount = State(initialValue: String(goal.wrappedValue.targetAmount))
        _editedDate = State(initialValue: goal.wrappedValue.targetCompletionDate)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Title", text: $editedTitle)

                    TextField("Target Amount", text: $editedAmount)
                        .keyboardType(.decimalPad)

                    DatePicker("Target Completion Date",
                              selection: $editedDate,
                              in: Date()...,
                              displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Goal")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    if let amount = Double(editedAmount) {
                        withAnimation {
                            var updatedGoal = goal
                            updatedGoal.title = editedTitle
                            updatedGoal.targetAmount = amount
                            updatedGoal.targetCompletionDate = editedDate
                            goal = updatedGoal
                        }
                        dismiss()
                    }
                }
            )
        }
    }
}


struct AIRecommendationCard: View {
    let goal: UserGoal
    @State private var isThinking = false

    var aiSuggestion: String {
        if goal.progressRate < 0.8 {
            return "Based on your spending patterns, try saving an extra $\(Int(goal.targetAmount * 0.1)) by reducing entertainment expenses."
        } else if goal.progressRate > 1.2 {
            return "Great progress! Consider increasing your target by 20% to maximize your potential."
        }
        return "You're right on track! Keep maintaining your current savings rate."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 24))
                    .foregroundColor(.purple)
                    .rotationEffect(.degrees(isThinking ? 10 : -10))
                    .animation(.easeInOut(duration: 1).repeatForever(), value: isThinking)

                Text("AI Suggestion")
                    .font(.headline)
                    .foregroundColor(.purple)
            }

            Text(aiSuggestion)
                .font(.subheadline)
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                .background(Color.white)
        )
        .onAppear { isThinking = true }
    }
}

struct SpendingPatternView: View {
    let transactions: [Transaction]
    @State private var selectedPattern: String = "Weekly"

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Smart Analysis")
                    .font(.headline)
                Spacer()
                Picker("Pattern", selection: $selectedPattern) {
                    Text("Weekly").tag("Weekly")
                    Text("Monthly").tag("Monthly")
                }
                .pickerStyle(.segmented)
            }

            // Animated bar chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7) { i in
                    VStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: CGFloat.random(in: 50...150))
                            .animation(.spring(), value: selectedPattern)

                        Text("D\(i+1)")
                            .font(.caption2)
                    }
                }
            }
            .padding(.vertical)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

struct AchievementProgressView: View {
    let goal: UserGoal
    @State private var showConfetti = false

    var progress: Double {
        min(goal.currentAmount / goal.targetAmount, 1.0)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Achievement Progress")
                    .font(.headline)
                Spacer()
                if progress >= 1.0 {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(showConfetti ? 360 : 0))
                        .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showConfetti)
                }
            }

            // Level progress
            HStack {
                Text("Level \(Int(progress * 10))")
                    .font(.subheadline)
                    .fontWeight(.bold)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Custom progress bar with floating particles
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                        .cornerRadius(10)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 20)
                        .cornerRadius(10)

                    // Floating particles
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 6, height: 6)
                            .offset(x: geometry.size.width * progress - CGFloat(i * 20))
                            .opacity(showConfetti ? 1 : 0)
                            .animation(
                                Animation.easeInOut(duration: 1)
                                    .repeatForever()
                                    .delay(Double(i) * 0.2),
                                value: showConfetti
                            )
                    }
                }
            }
            .frame(height: 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
        .onAppear {
            showConfetti = true
        }
    }
}