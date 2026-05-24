import Foundation
import SwiftData

@Model
final class DailyProgress {
    var id: UUID
    var date: Date
    var dateKey: String
    var pagesRead: Int
    var goalPages: Int
    var totalReadingTime: TimeInterval
    var sessionsCount: Int
    var wasGoalMet: Bool
    var unlockTime: Date?
    var streakDay: Int
    var xpEarned: Int
    
    init(date: Date = Date(), goalPages: Int = 20) {
        self.id = UUID()
        self.date = date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.dateKey = formatter.string(from: date)
        
        self.pagesRead = 0
        self.goalPages = goalPages
        self.totalReadingTime = 0
        self.sessionsCount = 0
        self.wasGoalMet = false
        self.unlockTime = nil
        self.streakDay = 0
        self.xpEarned = 0
    }
    
    func addPages(_ count: Int, readingTime: TimeInterval) {
        pagesRead += count
        totalReadingTime += readingTime
        sessionsCount += 1
        
        if pagesRead >= goalPages && !wasGoalMet {
            wasGoalMet = true
            unlockTime = Date()
            xpEarned += 100 + (streakDay * 10)
        }
        
        // Bonus XP for reading
        xpEarned += count * 5
    }
}
