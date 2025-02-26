import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    @Published var isPermissionGranted = false
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if !notificationsEnabled {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }
        }
    }

    private init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        checkNotificationPermission()
    }

    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
            }
        }
    }

    func scheduleNotifications(hasChallenge: Bool, hasActiveGoals: Bool) {
        // First remove all pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // Only schedule if permission is granted
        if !isPermissionGranted {
            requestPermission()
            return
        }

        // Challenge reminder
        if !hasChallenge {
            scheduleNotification(
                identifier: "dailyChallenge",
                title: "Time for Today's Money Move! 💰",
                body: "Complete a financial challenge to keep your streak going!",
                hour: 8,
                minute: 24
            )
        }

        // Learning reminder
        scheduleNotification(
            identifier: "learning",
            title: "Keep Learning! 📚",
            body: "Take a moment to expand your financial knowledge.",
            hour: 12,
            minute: 0
        )

        // Goals check-in
        if hasActiveGoals {
            scheduleNotification(
                identifier: "goals",
                title: "Check Your Vision 👑",
                body: "Building generational wealth starts with you. Stay locked in! 🎯",
                hour: 20,
                minute: 24
            )
        }
    }

    private func scheduleNotification(identifier: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    }