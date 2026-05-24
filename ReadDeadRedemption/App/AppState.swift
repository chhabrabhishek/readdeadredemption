import SwiftUI

@Observable
final class AppState {
    var isOnboardingComplete: Bool = false
    var isAuthorized: Bool = false
    var currentTab: AppTab = .dashboard
    var dailyProgress: Int = 0
    var dailyGoal: Int = 20
    var isUnlocked: Bool = false
    
    let storeKitManager = StoreKitManager.shared
    var preferences = AppPreferences()
    private let defaults = UserDefaults.standard
    
    enum AppTab: Int, CaseIterable {
        case dashboard
        case reading
        case analytics
        case settings
    }
    
    func initialize() async {
        isOnboardingComplete = defaults.bool(forKey: "onboardingComplete") ?? false
        dailyGoal = defaults.integer(forKey: "dailyGoal") ?? 20
        dailyProgress = defaults.integer(forKey: "todayProgress_\(todayKey)") ?? 0
        
        if dailyGoal == 0 { dailyGoal = 20 }
        updateUnlockState()
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        defaults.set(true, forKey: "onboardingComplete")
    }
    
    func recordPagesRead(_ pages: Int) {
        dailyProgress += pages
        defaults.set(dailyProgress, forKey: "todayProgress_\(todayKey)")
        updateUnlockState()
    }
    
    func updateUnlockState() {
        isUnlocked = dailyProgress >= dailyGoal
        defaults.set(isUnlocked, forKey: "isUnlocked")
    }
    
    private var todayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// MARK: - App Preferences (in-memory, synced to UserDefaults)

@Observable
final class AppPreferences {
    var dailyPageGoal: Int = 20
    var goalType: GoalType = .pages
    var motivationStyle: MotivationStyle = .balanced
    var unlockDuration: UnlockDuration = .untilMidnight
    var notificationsEnabled: Bool = true
    var streakNotifications: Bool = true
    var strictMode: Bool = false
}
