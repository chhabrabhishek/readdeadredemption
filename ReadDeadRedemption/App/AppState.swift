import SwiftUI

@Observable
final class AppState {
    var isOnboardingComplete: Bool = false
    var isAuthorized: Bool = false
    var currentTab: AppTab = .dashboard
    var dailyProgress: Int = 0
    var dailyGoal: Int = 20
    var isUnlocked: Bool = false
    
    // Screen Time is disabled — requires paid Apple Developer account
    // private let screenTimeManager = ScreenTimeManager.shared
    private let defaults = UserDefaults(suiteName: "group.com.yourcompany.readdeadredemption")
    
    enum AppTab: Int, CaseIterable {
        case dashboard
        case reading
        case analytics
        case settings
    }
    
    func initialize() async {
        isOnboardingComplete = defaults?.bool(forKey: "onboardingComplete") ?? false
        dailyGoal = defaults?.integer(forKey: "dailyGoal") ?? 20
        dailyProgress = defaults?.integer(forKey: "todayProgress_\(todayKey)") ?? 0
        
        if dailyGoal == 0 { dailyGoal = 20 }
        
        // Skip Screen Time authorization on free account
        // await checkAuthorization()
        updateUnlockState()
    }
    
    func checkAuthorization() async {
        // Requires paid Apple Developer account for Family Controls
        // let center = AuthorizationCenter.shared
        // try await center.requestAuthorization(for: .individual)
        isAuthorized = false
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        defaults?.set(true, forKey: "onboardingComplete")
    }
    
    func recordPagesRead(_ pages: Int) {
        dailyProgress += pages
        defaults?.set(dailyProgress, forKey: "todayProgress_\(todayKey)")
        updateUnlockState()
    }
    
    func updateUnlockState() {
        isUnlocked = dailyProgress >= dailyGoal
        defaults?.set(isUnlocked, forKey: "isUnlocked")
    }
    
    private var todayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
