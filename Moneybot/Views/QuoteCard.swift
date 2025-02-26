import SwiftUI

struct QuoteCard: View {
    @Environment(\.colorScheme) var colorScheme
    let quote: MoneyQuote
    @State private var isAnimating = false
    @State private var glowOpacity = 0.5

    var body: some View {
        VStack(spacing: 20) {
            // Animated glow effect
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 80 + CGFloat(i * 20))
                        .blur(radius: CGFloat(i * 2))
                        .opacity(glowOpacity)
                }

                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.purple)
                    .shadow(color: .purple.opacity(0.5), radius: 10)
                    .rotationEffect(.degrees(isAnimating ? 5 : -5))
            }
            .padding()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Text(quote.quote)
                        .font(.system(size: 22, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .lineSpacing(8)
                        .minimumScaleFactor(0.7)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 10)

                    Text("- \(quote.author)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.purple.opacity(0.8))
                        .padding(.bottom, 10)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 400)
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [.white, Color.purple.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.8), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: .purple.opacity(0.2), radius: 15)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [.purple.opacity(0.8), .purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .background(
            ZStack {
                ForEach(0..<5) { i in
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: CGFloat.random(in: 50...150))
                        .offset(x: CGFloat.random(in: -100...100),
                               y: CGFloat.random(in: -100...100))
                        .blur(radius: CGFloat.random(in: 5...20))
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever()
                                .delay(Double(i) * 0.3),
                            value: isAnimating
                        )
                }
            }
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever()) {
                isAnimating = true
                glowOpacity = 0.8
            }
        }
    }
}