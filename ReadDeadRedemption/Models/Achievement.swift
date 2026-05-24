import Foundation
import SwiftData

@Model
final class Achievement {
    var id: UUID
    var title: String
    var subtitle: String
    var iconName: String
    var category: Category
    var requirement: Int
    var currentProgress: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    var xpReward: Int
    
    enum Category: String, Codable, CaseIterable {
        case streaks = "Streaks"
        case pages = "Pages"
        case sessions = "Sessions"
        case focus = "Focus"
        case special = "Special"
    }
    
    init(
        title: String,
        subtitle: String,
        iconName: String,
        category: Category,
        requirement: Int,
        xpReward: Int
    ) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.category = category
        self.requirement = requirement
        self.currentProgress = 0
        self.isUnlocked = false
        self.unlockedDate = nil
        self.xpReward = xpReward
    }
    
    func checkUnlock() -> Bool {
        if !isUnlocked && currentProgress >= requirement {
            isUnlocked = true
            unlockedDate = Date()
            return true
        }
        return false
    }
    
    var progress: Double {
        guard requirement > 0 else { return 0 }
        return min(Double(currentProgress) / Double(requirement), 1.0)
    }
    
    static let defaults: [Achievement] = [
        Achievement(title: "First Page", subtitle: "Read your first page", iconName: "book.fill", category: .pages, requirement: 1, xpReward: 10),
        Achievement(title: "Bookworm", subtitle: "Read 100 pages total", iconName: "book.closed.fill", category: .pages, requirement: 100, xpReward: 50),
        Achievement(title: "Scholar", subtitle: "Read 500 pages total", iconName: "graduationcap.fill", category: .pages, requirement: 500, xpReward: 200),
        Achievement(title: "Librarian", subtitle: "Read 1000 pages total", iconName: "books.vertical.fill", category: .pages, requirement: 1000, xpReward: 500),
        Achievement(title: "On Fire", subtitle: "3-day reading streak", iconName: "flame.fill", category: .streaks, requirement: 3, xpReward: 30),
        Achievement(title: "Unstoppable", subtitle: "7-day reading streak", iconName: "bolt.fill", category: .streaks, requirement: 7, xpReward: 100),
        Achievement(title: "Iron Will", subtitle: "30-day reading streak", iconName: "shield.fill", category: .streaks, requirement: 30, xpReward: 500),
        Achievement(title: "Legend", subtitle: "100-day reading streak", iconName: "crown.fill", category: .streaks, requirement: 100, xpReward: 2000),
        Achievement(title: "Focus Master", subtitle: "Complete 10 focus sessions", iconName: "brain.fill", category: .focus, requirement: 10, xpReward: 100),
        Achievement(title: "Early Bird", subtitle: "Read before 7 AM", iconName: "sunrise.fill", category: .special, requirement: 1, xpReward: 25),
    ]
}
