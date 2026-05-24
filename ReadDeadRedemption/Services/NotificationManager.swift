import Foundation
import UserNotifications

/// Manages local notifications for reading reminders, streaks, and encouragement
final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            return false
        }
    }
    
    // MARK: - Scheduled Notifications
    
    func scheduleDailyReminder(at hour: Int, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Read 📚"
        content.body = "Your apps are waiting. Complete your reading goal to unlock them!"
        content.sound = .default
        content.categoryIdentifier = "READING_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleStreakReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak! 🔥"
        content.body = "You haven't read today yet. Keep your streak alive!"
        content.sound = .default
        content.categoryIdentifier = "STREAK_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8 PM reminder
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streak_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func sendUnlockNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Apps Unlocked! 🎉"
        content.body = "Great job! You've completed your reading goal. Your apps are now available."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "unlock_\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func sendStreakMilestone(_ days: Int) {
        let content = UNMutableNotificationContent()
        content.title = "\(days)-Day Streak! 🏆"
        content.body = "Incredible dedication! You've read for \(days) days straight."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "streak_milestone_\(days)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Cancellation
    
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily_reminder", "streak_reminder"]
        )
    }
}
