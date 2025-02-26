
import SwiftUI

struct DesignSystem {
    // Gaming-inspired color palette
    static let primaryGreen = Color(red: 0.0, green: 0.8, blue: 0.4)
    static let secondaryGreen = Color(red: 0.0, green: 0.7, blue: 0.3)
    static let glowGreen = Color(red: 0.0, green: 0.9, blue: 0.4)
    static let accentPurple = Color(red: 0.6, green: 0.2, blue: 0.8)
    static let accentBlue = Color(red: 0.2, green: 0.6, blue: 0.9)
    
    struct Typography {
        static let gameTitle = Font.system(size: 28, weight: .black, design: .rounded)
        static let title = Font.system(size: 24, weight: .bold, design: .rounded)
        static let subtitle = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .medium, design: .rounded)
        static let caption = Font.system(size: 14, weight: .medium, design: .rounded)
    }
    
    struct Effects {
        static func glowBackground(_ color: Color = primaryGreen) -> some View {
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 200)
                        .blur(radius: 50)
                        .offset(x: CGFloat.random(in: -100...100),
                                y: CGFloat.random(in: -100...100))
                }
            }
        }
        
        static func gameCardStyle(color: Color = primaryGreen) -> some ViewModifier {
            GameCardModifier(color: color)
        }
    }
}

struct GameCardModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.white, color.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Holographic effect
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.1),
                                    color.opacity(0.05),
                                    color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .opacity(0.5)
                    
                    // Border glow
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.8),
                                    color.opacity(0.2),
                                    color.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            )
            .shadow(color: color.opacity(0.2), radius: 15)
    }
}

extension View {
    func gameCardStyle(color: Color = DesignSystem.primaryGreen) -> some View {
        modifier(DesignSystem.Effects.gameCardStyle(color: color))
    }
    
    func challengeCardStyle() -> some View {
        self.modifier(ChallengePressableStyle())
    }
}

struct ChallengePressableStyle: ViewModifier {
    @State private var isPressed = false
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .background(
                ZStack {
                    Circle()
                        .fill(DesignSystem.glowGreen.opacity(0.1))
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .blur(radius: 20)
                        .offset(x: -100, y: -50)
                    Circle()
                        .fill(DesignSystem.accentBlue.opacity(0.1))
                        .scaleEffect(isAnimating ? 0.8 : 1.2)
                        .blur(radius: 20)
                        .offset(x: 100, y: 50)
                }
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            .onTapGesture {
                withAnimation {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                }
            }
    }
}
