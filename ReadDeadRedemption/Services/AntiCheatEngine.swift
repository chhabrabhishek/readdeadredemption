import Foundation

/// Anti-cheat engine that validates reading behavior
/// Prevents fake reading through multiple heuristic checks
@Observable
final class AntiCheatEngine {
    static let shared = AntiCheatEngine()
    
    // MARK: - Configuration
    
    /// Minimum seconds a user must spend on a page for it to count
    private let minimumPageTime: TimeInterval = 15.0
    
    /// Maximum reasonable reading speed (pages per minute)
    private let maxPagesPerMinute: Double = 4.0
    
    /// Minimum scroll velocity threshold (too fast = skimming)
    private let maxScrollVelocity: Double = 5000.0
    
    /// Maximum idle time before session is considered abandoned
    private let maxIdleTime: TimeInterval = 300.0 // 5 minutes
    
    /// Minimum engagement ratio (active time / total time)
    private let minimumEngagementRatio: Double = 0.6
    
    private init() {}
    
    // MARK: - Session Validation
    
    /// Validates an entire reading session and returns the number of legitimately read pages
    func validateSession(
        pagesRead: Int,
        duration: TimeInterval,
        pageTimestamps: [Date],
        scrollVelocities: [Double]
    ) -> Int {
        guard pagesRead > 0, duration > 0 else { return 0 }
        
        var validPages = 0
        
        // Check 1: Overall reading speed
        let pagesPerMinute = Double(pagesRead) / (duration / 60.0)
        if pagesPerMinute > maxPagesPerMinute {
            // Reading too fast overall - cap at reasonable speed
            let maxReasonablePages = Int(maxPagesPerMinute * (duration / 60.0))
            return min(maxReasonablePages, pagesRead)
        }
        
        // Check 2: Individual page times
        validPages = validatePageTransition(from: [], timestamps: pageTimestamps)
        
        // Check 3: Scroll velocity analysis
        let suspiciousScrolls = scrollVelocities.filter { $0 > maxScrollVelocity }
        let scrollCheatingRatio = Double(suspiciousScrolls.count) / max(Double(scrollVelocities.count), 1.0)
        
        if scrollCheatingRatio > 0.5 {
            // More than half the scrolls were suspicious
            validPages = Int(Double(validPages) * 0.5)
        }
        
        // Check 4: Session duration minimum
        let minimumSessionTime = Double(pagesRead) * minimumPageTime
        if duration < minimumSessionTime * 0.5 {
            validPages = max(1, validPages / 2)
        }
        
        return max(0, validPages)
    }
    
    /// Validates individual page transitions based on timestamps
    func validatePageTransition(
        from transitions: [(page: Int, timestamp: Date)],
        timestamps: [Date]
    ) -> Int {
        guard timestamps.count >= 2 else { return 0 }
        
        var validPages = 0
        
        for i in 1..<timestamps.count {
            let timeOnPage = timestamps[i].timeIntervalSince(timestamps[i - 1])
            
            // Page counts if user spent minimum time on it
            if timeOnPage >= minimumPageTime {
                validPages += 1
            } else if timeOnPage >= minimumPageTime * 0.5 {
                // Partial credit for slightly fast reading (experienced readers)
                validPages += 1
            }
            // Skip pages that were flipped too quickly
        }
        
        return validPages
    }
    
    // MARK: - Real-time Checks
    
    /// Check if current page flip is suspicious
    func isPageFlipSuspicious(timeSinceLastFlip: TimeInterval) -> Bool {
        return timeSinceLastFlip < 3.0 // Less than 3 seconds is definitely suspicious
    }
    
    /// Detect if user appears idle
    func detectIdle(lastInteractionTime: Date) -> Bool {
        return Date().timeIntervalSince(lastInteractionTime) > maxIdleTime
    }
    
    /// Calculate engagement score (0.0 to 1.0)
    func calculateEngagementScore(
        activeTime: TimeInterval,
        totalTime: TimeInterval,
        pagesRead: Int,
        averagePageTime: TimeInterval
    ) -> Double {
        guard totalTime > 0 else { return 0 }
        
        var score = 0.0
        
        // Time engagement
        let timeRatio = activeTime / totalTime
        score += timeRatio * 0.4
        
        // Reading pace score
        let idealPageTime: TimeInterval = 45.0 // ~45 seconds per page is ideal
        let paceDeviation = abs(averagePageTime - idealPageTime) / idealPageTime
        let paceScore = max(0, 1.0 - paceDeviation)
        score += paceScore * 0.3
        
        // Consistency score
        let expectedPages = Int(totalTime / idealPageTime)
        let consistencyRatio = expectedPages > 0 ? Double(pagesRead) / Double(expectedPages) : 0
        score += min(consistencyRatio, 1.0) * 0.3
        
        return min(score, 1.0)
    }
    
    // MARK: - Comprehension Check
    
    /// Generates a simple comprehension prompt (for future AI integration)
    func shouldTriggerComprehensionCheck(pagesRead: Int, sessionDuration: TimeInterval) -> Bool {
        // Trigger check every 10 pages or every 15 minutes
        return pagesRead > 0 && (pagesRead % 10 == 0 || Int(sessionDuration) % 900 == 0)
    }
}
