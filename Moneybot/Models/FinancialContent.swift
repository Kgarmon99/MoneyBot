
import Foundation

struct FinancialGoal: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let targetAmount: Double
    let icon: String
    let category: GoalCategory
}

enum GoalCategory: String {
    case emergency = "Emergency Fund"
    case retirement = "Retirement"
    case investment = "Investment"
    case debt = "Debt Payment"
    case education = "Education"
    case home = "Home Purchase"
    case vacation = "Vacation"
    case business = "Business"
    case tech = "Tech Gadgets"
    case gaming = "Gaming Setup"
    case fitness = "Fitness Goals"
    case crypto = "Crypto Portfolio"
    case sideHustle = "Side Hustle"
    case streaming = "Content Creation"
}

struct MoneyQuote: Identifiable {
    let id = UUID()
    let quote: String
    let author: String
}

struct FinancialTip: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let icon: String
}

class FinancialContent {
    static let goals = [
        FinancialGoal(title: "Emergency Fund", description: "Build 3-6 months of expenses", targetAmount: 10000, icon: "shield.fill", category: .emergency),
        FinancialGoal(title: "Student Debt Crusher", description: "Pay off those student loans", targetAmount: 30000, icon: "creditcard.fill", category: .debt),
        FinancialGoal(title: "Dream Gaming PC", description: "Build ultimate gaming setup", targetAmount: 3000, icon: "gamecontroller.fill", category: .gaming),
        FinancialGoal(title: "Latest iPhone Fund", description: "Save for next iPhone", targetAmount: 1200, icon: "iphone", category: .tech),
        FinancialGoal(title: "Crypto Portfolio", description: "Build diverse crypto holdings", targetAmount: 5000, icon: "bitcoinsign.circle.fill", category: .crypto),
        FinancialGoal(title: "ETF Investment", description: "Start index fund portfolio", targetAmount: 5000, icon: "chart.line.uptrend.xyaxis", category: .investment),
        FinancialGoal(title: "Streaming Setup", description: "Build Twitch/YouTube studio", targetAmount: 2000, icon: "video.fill", category: .streaming),
        FinancialGoal(title: "Dropshipping Startup", description: "Launch online business", targetAmount: 1000, icon: "cart.fill", category: .sideHustle)
    ]

    static let tips = [
        // Saving & Budgeting
        FinancialTip(title: "Compound Interest", content: "Start investing early - time is your greatest asset", icon: "repeat.circle.fill"),
        FinancialTip(title: "24-Hour Rule", content: "Wait 24 hours before making any non-essential purchase over $50", icon: "clock.fill"),
        FinancialTip(title: "Automate Savings", content: "Set up automatic transfers on payday to your savings account", icon: "arrow.right.circle.fill"),
        FinancialTip(title: "Bill Audit", content: "Review and negotiate bills every 6 months", icon: "doc.text.magnifyingglass"),
        FinancialTip(title: "Save First", content: "Save before spending, not after", icon: "arrow.up.circle.fill"),
        FinancialTip(title: "Expense Tracking", content: "Track every expense for a month to understand your spending patterns", icon: "list.bullet.clipboard.fill"),
        
        // Investing
        FinancialTip(title: "Dollar-Cost Average", content: "Invest fixed amounts regularly instead of timing the market", icon: "chart.line.uptrend.xyaxis"),
        FinancialTip(title: "Risk Management", content: "Never invest more than you can afford to lose", icon: "exclamationmark.shield.fill"),
        FinancialTip(title: "Portfolio Balance", content: "Rebalance your portfolio annually", icon: "scale.3d"),
        
        // Debt Management
        FinancialTip(title: "Debt Snowball", content: "Pay off smallest debts first for psychological wins", icon: "snow"),
        FinancialTip(title: "Debt Avalanche", content: "Focus on highest interest debt first to minimize interest paid", icon: "mountain.2.fill"),
    
        // Side Hustles
        FinancialTip(title: "Skill Monetization", content: "Turn your hobbies into income streams", icon: "hammer.fill"),
        FinancialTip(title: "Digital Products", content: "Create once, sell infinitely - ebooks, courses, templates", icon: "cpu.fill"),
        FinancialTip(title: "Gig Economy", content: "Use free time for ride-sharing or delivery services", icon: "car.fill"),
        
        // Tech-Smart Money
  
        FinancialTip(title: "Subscription Audit", content: "Review digital subscriptions monthly", icon: "repeat.circle"),
        FinancialTip(title: "Price Tracking", content: "Use price tracking apps for big purchases", icon: "tag.fill"),
        
        // Career & Income
        FinancialTip(title: "Skill Development", content: "Invest in skills that increase your earning potential", icon: "brain.head.profile"),
        FinancialTip(title: "Salary Research", content: "Know your market value and negotiate accordingly", icon: "dollarsign.circle.fill"),
        FinancialTip(title: "Multiple Income", content: "Build multiple income streams for security", icon: "arrow.triangle.branch")
    ]

    static let quotes = [
        // Modern Financial Wisdom
        MoneyQuote(quote: "The best investment you can make is in yourself.", author: "Warren Buffett"),
        MoneyQuote(quote: "Create value first, money follows.", author: "Mark Cuban"),
        MoneyQuote(quote: "Money is a terrible master but an excellent servant.", author: "P.T. Barnum"),
        MoneyQuote(quote: "Don't save what's left after spending; spend what's left after saving.", author: "Warren Buffett"),
        MoneyQuote(quote: "Financial freedom is mental freedom.", author: "Robert Kiyosaki"),
        
        
        // Tech Era Finance
        MoneyQuote(quote: "In a digital world, your skills are your assets.", author: "Naval Ravikant"),
        MoneyQuote(quote: "Start small, think big, scale fast.", author: "Gary Vaynerchuk"),
  
        
        // Personal Development
        MoneyQuote(quote: "Invest in yourself. Your career is the engine of your wealth.", author: "Paul Clitheroe"),
        MoneyQuote(quote: "Your network is your net worth.", author: "Porter Gale"),
        MoneyQuote(quote: "Knowledge plus action equals power.", author: "Tony Robbins"),
        
        // Financial Independence
        MoneyQuote(quote: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
        MoneyQuote(quote: "Time is more valuable than money. You can get more money, but you cannot get more time.", author: "Jim Rohn"),
       
        // Digital Age Success
     
       
        
        // Wealth Building
        MoneyQuote(quote: "Wealth is the ability to fully experience life.", author: "Henry David Thoreau"),
        MoneyQuote(quote: "It's not how much money you make, but how much money you keep.", author: "Robert Kiyosaki"),
    ]
}
