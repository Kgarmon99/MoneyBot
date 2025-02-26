
import SwiftUI

struct RewardView: View {
    let amount: Int
    @Binding var isVisible: Bool
    @State private var rotationAngle = 0.0
    @State private var scaleEffect = 1.0
    let glowGreen = Color(red: 0.0, green: 0.8, blue: 0.4)
    
    var body: some View {
        VStack {
            Text("+\(amount) XP")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.green)
                .padding(24)
                .background(
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.white, Color.green.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: glowGreen.opacity(0.5), radius: 15)
                        
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(glowGreen.opacity(0.3), lineWidth: 2)
                                .scaleEffect(isVisible ? 1.5 + Double(i) * 0.2 : 1)
                                .opacity(isVisible ? 0 : 1)
                                .animation(
                                    .easeOut(duration: 1)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(i) * 0.2),
                                    value: isVisible
                                )
                        }
                    }
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [glowGreen.opacity(0.8), glowGreen.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .scaleEffect(isVisible ? 1.2 : 0.5)
                .opacity(isVisible ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isVisible)
                .shadow(color: glowGreen.opacity(0.3), radius: 20)
                .shadow(color: glowGreen.opacity(0.2), radius: 40)
                .rotationEffect(.degrees(rotationAngle))
                .scaleEffect(scaleEffect)
                .onAppear {
                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                    withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                        scaleEffect = 1.1
                    }
                }
                
                // Floating particles
                ForEach(0..<8) { i in
                    Circle()
                        .fill(glowGreen)
                        .frame(width: 8, height: 8)
                        .offset(x: CGFloat.random(in: -50...50),
                               y: CGFloat.random(in: -50...50))
                        .opacity(0.5)
                        .blur(radius: 2)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever()
                                .delay(Double(i) * 0.2),
                            value: isVisible
                        )
                }
        }
    }
}
