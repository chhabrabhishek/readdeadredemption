import BackgroundTasks
import Foundation

/// Handles background task registration and execution
final class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private let dailyResetIdentifier = "com.readdeadredemption.dailyreset"
    private let streakCheckIdentifier = "com.readdeadredemption.streakcheck"
    
    private init() {}
    
    // MARK: - Registration
    
    func registerTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: dailyResetIdentifier,
            using: nil
        ) { task in
            self.handleDailyReset(task: task as! BGProcessingTask)
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: streakCheckIdentifier,
            using: nil
        ) { task in
            self.handleStreakCheck(task: task as! BGAppRefreshTask)
        }
    }
    
    // MARK: - Scheduling
    
    func scheduleDailyReset() {
        let request = BGProcessingTaskRequest(identifier: dailyResetIdentifier)
        
        // Schedule for midnight
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let midnight = calendar.startOfDay(for: tomorrow)
        request.earliestBeginDate = midnight
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule daily reset: \(error)")
        }
    }
    
    func scheduleStreakCheck() {
        let request = BGAppRefreshTaskRequest(identifier: streakCheckIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // 1 hour
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule streak check: \(error)")
        }
    }
    
    // MARK: - Task Handlers
    
    private func handleDailyReset(task: BGProcessingTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        let defaults = UserDefaults(suiteName: "group.com.yourcompany.readdeadredemption")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayKey = formatter.string(from: Date())
        
        // Reset daily progress
        defaults?.set(0, forKey: "todayProgress_\(todayKey)")
        defaults?.set(false, forKey: "isUnlocked")
        
        // Re-lock apps
        Task {
            await ScreenTimeManager.shared.lockApps()
        }
        
        task.setTaskCompleted(success: true)
        
        // Reschedule for next day
        scheduleDailyReset()
    }
    
    private func handleStreakCheck(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        let defaults = UserDefaults(suiteName: "group.com.yourcompany.readdeadredemption")
        let isUnlocked = defaults?.bool(forKey: "isUnlocked") ?? false
        
        // If it's late in the day and user hasn't read, send reminder
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 20 && !isUnlocked {
            NotificationManager.shared.scheduleStreakReminder()
        }
        
        task.setTaskCompleted(success: true)
        scheduleStreakCheck()
    }
}
