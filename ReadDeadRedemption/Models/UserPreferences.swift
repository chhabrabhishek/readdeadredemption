import Foundation
import SwiftData

// MARK: - Enums (top-level so all files can access them)

enum GoalType: String, Codable, CaseIterable {
    case pages = "Pages"
    case minutes = "Minutes"
}

enum MotivationStyle: String, Codable, CaseIterable {
    case strict = "Strict"
    case balanced = "Balanced"
    case gentle = "Gentle"
    
    var description: String {
        switch self {
        case .strict: return "No mercy. Apps stay locked until you read."
        case .balanced: return "Firm but fair. Occasional grace periods."
        case .gentle: return "Encouraging nudges with flexible goals."
        }
    }
    
    var icon: String {
        switch self {
        case .strict: return "flame.fill"
        case .balanced: return "scale.3d"
        case .gentle: return "leaf.fill"
        }
    }
}

enum UnlockDuration: String, Codable, CaseIterable {
    case twoHours = "2 Hours"
    case fourHours = "4 Hours"
    case untilMidnight = "Until Midnight"
    case allDay = "All Day"
    
    var seconds: TimeInterval {
        switch self {
        case .twoHours: return 7200
        case .fourHours: return 14400
        case .untilMidnight:
            let calendar = Calendar.current
            let now = Date()
            let midnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
            return midnight.timeIntervalSince(now)
        case .allDay: return 86400
        }
    }
}

// MARK: - SwiftData Model

@Model
final class UserPreferences {
    var id: UUID
    var dailyPageGoal: Int
    var dailyMinuteGoal: Int
    var goalType: GoalType
    var motivationStyle: MotivationStyle
    var unlockDuration: UnlockDuration
    var readingScheduleStart: Date
    var readingScheduleEnd: Date
    var notificationsEnabled: Bool
    var focusSoundsEnabled: Bool
    var hapticFeedbackEnabled: Bool
    var isPremium: Bool
    var currentStreak: Int
    var longestStreak: Int
    var totalXP: Int
    var level: Int
    var selectedAppsData: Data?
    
    init() {
        self.id = UUID()
        self.dailyPageGoal = 20
        self.dailyMinuteGoal = 30
        self.goalType = .pages
        self.motivationStyle = .balanced
        self.unlockDuration = .untilMidnight
        self.readingScheduleStart = Calendar.current.date(from: DateComponents(hour: 6)) ?? Date()
        self.readingScheduleEnd = Calendar.current.date(from: DateComponents(hour: 23)) ?? Date()
        self.notificationsEnabled = true
        self.focusSoundsEnabled = false
        self.hapticFeedbackEnabled = true
        self.isPremium = false
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalXP = 0
        self.level = 1
        self.selectedAppsData = nil
    }
}
