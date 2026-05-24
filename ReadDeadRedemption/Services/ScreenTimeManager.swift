import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Manages Screen Time API interactions for app blocking/unblocking
@Observable
final class ScreenTimeManager {
    static let shared = ScreenTimeManager()
    
    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()
    private let defaults = UserDefaults(suiteName: "group.com.yourcompany.readdeadredemption")
    
    var activitySelection = FamilyActivitySelection() {
        didSet {
            saveSelection()
        }
    }
    
    var isAuthorized: Bool = false
    var blockedAppsCount: Int = 0
    
    private init() {
        loadSelection()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        isAuthorized = true
    }
    
    // MARK: - App Blocking
    
    func lockApps() async {
        guard !activitySelection.applicationTokens.isEmpty else { return }
        
        let applications = activitySelection.applicationTokens
        let categories = activitySelection.categoryTokens
        
        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy.specific(categories)
        
        store.shield.webDomains = activitySelection.webDomainTokens
        
        blockedAppsCount = applications.count
        defaults?.set(false, forKey: "isUnlocked")
        
        // Start monitoring schedule
        startMonitoring()
    }
    
    func unlockApps() async {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        
        blockedAppsCount = 0
        defaults?.set(true, forKey: "isUnlocked")
        
        // Stop monitoring
        center.stopMonitoring()
    }
    
    // MARK: - Device Activity Monitoring
    
    private func startMonitoring() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            try center.startMonitoring(
                .daily,
                during: schedule
            )
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }
    
    // MARK: - Persistence
    
    private func saveSelection() {
        do {
            let data = try JSONEncoder().encode(activitySelection)
            defaults?.set(data, forKey: "selectedApps")
        } catch {
            print("Failed to save selection: \(error)")
        }
    }
    
    func loadSelection() {
        guard let data = defaults?.data(forKey: "selectedApps") else { return }
        do {
            activitySelection = try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
            blockedAppsCount = activitySelection.applicationTokens.count
        } catch {
            print("Failed to load selection: \(error)")
        }
    }
    
    // MARK: - Status
    
    var isBlocking: Bool {
        !(defaults?.bool(forKey: "isUnlocked") ?? false)
    }
}

// MARK: - DeviceActivity Name Extension

extension DeviceActivityName {
    static let daily = Self("readdeadredemption.daily")
}

extension DeviceActivityEvent.Name {
    static let dailyReset = Self("readdeadredemption.dailyReset")
}
