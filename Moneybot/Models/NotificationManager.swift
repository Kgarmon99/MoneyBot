import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotifications(hasChallenge: Bool, hasActiveGoals: Bool) {
        // Cancel existing notifications to avoid duplicates
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule daily reminders
        scheduleDailyReminder(at: 9, title: "Morning Motivation", body: "Rise and shine! Let's make financial progress today 💰")
        
        // Challenge reminder (if active)
        if hasChallenge {
            scheduleRandomReminder(
                title: "Challenge Check-in",
                body: "How's your financial challenge going? Tap to update your progress!",
                timeRange: (10, 17) // Between 10 AM and 5 PM
            )
        }
        
        // Goal reminder (if has active goals)
        if hasActiveGoals {
            scheduleRandomReminder(
                title: "Goal Progress",
                body: "Remember your financial goals? Check in on your progress!",
                timeRange: (13, 19) // Between 1 PM and 7 PM
            )
        }
        
        // Evening reflection regardless of challenge/goal status
        scheduleDailyReminder(at: 20, title: "Evening Reflection", body: "Take a moment to review your finances today.")
        
        // Ask Moneybot reminder
        scheduleRandomReminder(
            title: "Moneybot Tip",
            body: "Ask me a question about money! I'm here to help with your finances.",
            timeRange: (12, 18) // Between 12 PM and 6 PM
        )
    }
    
    private func scheduleDailyReminder(at hour: Int, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleRandomReminder(title: String, body: String, timeRange: (Int, Int)) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Schedule for tomorrow at random time within range
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.day! += 1 // Next day
        components.hour = Int.random(in: timeRange.0...timeRange.1)
        components.minute = Int.random(in: 0...59)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error.localizedDescription)")
            }
        }
    }
}
