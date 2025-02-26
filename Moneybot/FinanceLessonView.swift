
import SwiftUI

struct FinanceLessonView: View {
    @Binding var user: User
    @Binding var isPresented: Bool
    
    let financeTips = [
        (title: "Emergency Fund Basics", tip: "Start with saving 3-6 months of expenses. Even $500 saved can help with unexpected costs.", icon: "creditcard.fill"),
        (title: "Smart Budgeting", tip: "Use the 50/30/20 rule: 50% for needs, 30% for wants, and 20% for savings and debt payments.", icon: "chart.pie.fill"),
        (title: "Debt Management", tip: "Pay off high-interest debt first while maintaining minimum payments on other debts.", icon: "dollarsign.circle.fill"),
        (title: "Investment 101", tip: "Start investing early, even with small amounts. Consider low-cost index funds for long-term growth.", icon: "arrow.up.right.circle.fill"),
        (title: "Saving Strategy", tip: "Set up automatic transfers to your savings account when you get paid - pay yourself first!", icon: "arrow.left.arrow.right.circle.fill"),
        (title: "Credit Score Tips", tip: "Keep credit utilization below 30% and always pay bills on time to maintain a good credit score.", icon: "lock.shield.fill"),
        (title: "Tax Planning", tip: "Take advantage of tax-advantaged accounts like 401(k)s and IRAs for retirement savings.", icon: "doc.text.fill"),
        (title: "Insurance Basics", tip: "Protect your finances with adequate health, auto, and if needed, life insurance.", icon: "heart.circle.fill")
    ]
    
    var randomTip: (title: String, tip: String, icon: String) {
        financeTips.randomElement() ?? financeTips[0]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    Image(systemName: randomTip.icon)
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 100, height: 100)
                        )
                    
                    Text(randomTip.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(randomTip.tip)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    Button(action: {
                        user.xp += 50
                        isPresented = false
                    }) {
                        HStack {
                            Text("Got it!")
                            Text("+50 XP")
                                .fontWeight(.bold)
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .padding(.horizontal)
                        .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.vertical, 40)
                .padding(.horizontal)
            }
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
    }
}
