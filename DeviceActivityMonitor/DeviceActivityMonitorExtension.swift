import DeviceActivity
import ManagedSettings
import Foundation

/// Monitors device activity events for daily resets and streak management
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let store = ManagedSettingsStore()
    
    // Called at the start of a new monitoring interval (midnight daily reset)
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // Re-apply shields at start of new day
        reapplyShields()
        
        // Reset daily page count
        let defaults = UserDefaults(suiteName: "group.com.yourcompany.readdeadredemption")
        
        // Check if yesterday's goal was met for streak
        let yesterdayPages = defaults?.integer(forKey: "todayPagesRead") ?? 0
        let goal = defaults?.integer(forKey: "dailyPageGoal") ?? 20
        
        if yesterdayPages >= goal {
            // Increment streak
            let currentStreak = defaults?.integer(forKey: "currentStreak") ?? 0
            defaults?.set(currentStreak + 1, forKey: "currentStreak")
        } else {
            // Reset streak
            defaults?.set(0, forKey: "currentStreak")
        }
        
        // Reset today's count
        defaults?.set(0, forKey: "todayPagesRead")
        defaults?.set(false, forKey: "goalMetToday")
    }
    
    // Called at the end of a monitoring interval
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
    }
    
    // Called when a monitored event threshold is reached
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
    }
    
    // MARK: - Helpers
    
    private func reapplyShields() {
        let defaults = UserDefaults(suiteName: "group.com.yourcompany.readdeadredemption")
        
        // Check if there are apps to block
        guard let selectionData = defaults?.data(forKey: "activitySelection") else { return }
        
        do {
            let selection = try JSONDecoder().decode(FamilyActivitySelection.self, from: selectionData)
            store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
            store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
            store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        } catch {
            // Silent failure in extension
        }
    }
}
