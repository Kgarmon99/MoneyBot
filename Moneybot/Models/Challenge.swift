import Foundation

struct Challenge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: ChallengeCategory
    let xpReward: Int
    let difficultyLevel: DifficultyLevel
    var progress: Double = 0.0
    var isInProgress: Bool = false
    var completionDate: Date?
    var steps: [ChallengeStep] = []
    
    mutating func updateProgress(_ newProgress: Double) {
        progress = min(max(newProgress, 0), 1)
        if progress >= 1 {
            completionDate = Date()
        }
    }
    
    mutating func toggleStep(_ index: Int) {
        guard index < steps.count else { return }
        steps[index].isCompleted.toggle()
        updateProgress(Double(steps.filter { $0.isCompleted }.count) / Double(steps.count))
    }
    
    mutating func resetSteps() {
        steps = steps.map { step in
            var newStep = step
            newStep.isCompleted = false
            return newStep
        }
        progress = 0.0
        completionDate = nil
    }
}

struct ChallengeStep: Identifiable {
    let id = UUID()
    let description: String
    var isCompleted: Bool = false
}

enum ChallengeCategory: String, CaseIterable {
    case saving = "Saving"
    case investing = "Investing"
    case budgeting = "Budgeting"
    case learning = "Learning"
    case crypto = "Crypto"
    case sideHustle = "Side Hustle"
    case tech = "Tech"
    case social = "Social"
}

enum DifficultyLevel: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    var unlocked: Bool
}

struct UserGoal: Identifiable, Codable {
    let id: UUID
    var title: String
    var targetAmount: Double
    var period: ProgressView.GoalPeriod
    var currentAmount: Double
    var targetCompletionDate: Date
    var milestones: [Milestone]
    var transactions: [Transaction]
    var startDate: Date

    var averageContribution: Double {
        transactions.isEmpty ? 0 : transactions.map { $0.amount }.reduce(0, +) / Double(transactions.count)
    }

    var progressRate: Double {
        let totalDays = Calendar.current.dateComponents([.day], from: startDate, to: targetCompletionDate).day ?? 1
        let targetDailyAmount = targetAmount / Double(totalDays)
        let currentDays = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 1
        let expectedAmount = targetDailyAmount * Double(currentDays)
        return currentAmount / expectedAmount
    }

    var estimatedCompletionDate: Date {
        targetCompletionDate
    }

    init(title: String, targetAmount: Double, period: ProgressView.GoalPeriod, currentAmount: Double = 0, targetCompletionDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()) {
        self.id = UUID()
        self.title = title
        self.targetAmount = targetAmount
        self.period = period
        self.currentAmount = currentAmount
        self.startDate = Date()
        self.targetCompletionDate = targetCompletionDate
        self.milestones = [
            Milestone(title: "25% Complete", targetAmount: targetAmount * 0.25),
            Milestone(title: "Halfway There!", targetAmount: targetAmount * 0.5),
            Milestone(title: "Almost Done", targetAmount: targetAmount * 0.75),
            Milestone(title: "Goal Complete!", targetAmount: targetAmount)
        ]
        self.transactions = []
    }
}

struct Milestone: Identifiable, Codable {
    let id: UUID
    let title: String
    let targetAmount: Double
    var isCompleted: Bool = false

    init(title: String, targetAmount: Double) {
        self.id = UUID()
        self.title = title
        self.targetAmount = targetAmount
    }
}

struct Transaction: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let date: Date
    let note: String

    init(amount: Double, date: Date, note: String) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.note = note
    }
}




extension User {
    func scheduleNotifications() {
        NotificationManager.shared.scheduleNotifications(
            hasChallenge: !dailyChallenge.isEmpty,
            hasActiveGoals: !activeGoals.isEmpty
        )
    }
}
