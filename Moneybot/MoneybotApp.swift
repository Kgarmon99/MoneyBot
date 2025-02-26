import SwiftUI

import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        // Request authorization immediately
        NotificationManager.shared.requestPermission()
        return true
    }

    // This method will be called when a notification is about to be presented while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // This method will be called when user taps on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}


@main
struct MoneybotApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreen()
                } else {
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .preferredColorScheme(.light)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        showSplash = false
                        // Check if it's first launch
                        if !UserDefaults.standard.bool(forKey: "hasRequestedNotifications") {
                            NotificationManager.shared.requestPermission()
                            UserDefaults.standard.set(true, forKey: "hasRequestedNotifications")
                        }
                    }
                }
            }
        }
    }
}

struct OrbitingCircle: View {
    let angle: Double
    let glowGreen: Color

    var body: some View {
        Circle()
            .fill(glowGreen)
            .frame(width: 6, height: 6)
            .offset(x: 100 * cos(angle),
                    y: 100 * sin(angle))
            .opacity(0.6)
            .blur(radius: 2)
    }
}

struct SplashScreen: View {
    @State private var glowIntensity: CGFloat = 0
    @State private var scale: CGFloat = 0.8
    @State private var rotationAngle: Double = 0
    @State private var isAnimating = false
    @State private var progress: CGFloat = 0
    @State private var showProgress = false

    let glowGreen = Color(red: 0.0, green: 0.8, blue: 0.4)

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            ZStack {
                // Orbital ring
                Circle()
                    .stroke(
                        glowGreen.opacity(0.15),
                        style: StrokeStyle(
                            lineWidth: 1,
                            lineCap: .round,
                            lineJoin: .round,
                            dash: [1, 3]
                        )
                    )
                    .scaleEffect(1.4)
                    .rotationEffect(.degrees(rotationAngle))

                // Orbiting elements
                ForEach(0..<6) { i in
                    OrbitingCircle(
                        angle: 2 * .pi * Double(i) / 6 + rotationAngle / 30,
                        glowGreen: glowGreen
                    )
                }

                // Main logo container
                ZStack {
                    Circle()
                        .fill(glowGreen.opacity(0.1))
                        .frame(width: 220, height: 220)
                        .blur(radius: 20)

                    Image("new-moneybot-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .shadow(color: glowGreen.opacity(0.5), radius: glowIntensity * 20)
                        .scaleEffect(scale)
                }
                // Loading bar
                if showProgress {
                    VStack {
                        Spacer()
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 200, height: 4)

                            RoundedRectangle(cornerRadius: 8)
                                .fill(glowGreen)
                                .frame(width: 200 * progress, height: 4)
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .onAppear {
            // Initial animations
            withAnimation(.easeOut(duration: 0.8)) {
                glowIntensity = 1
                scale = 1
                isAnimating = true
            }

            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }

            // Loading progress animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showProgress = true
                withAnimation(.easeInOut(duration: 0.8)) {
                    progress = 1.0
                }
            }
        }
    }
}