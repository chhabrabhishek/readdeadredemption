import Testing
@testable import ReadDeadRedemption

@Suite("Anti-Cheat Engine Tests")
struct AntiCheatTests {
    
    let engine = AntiCheatEngine()
    
    @Test("Validates normal reading speed")
    func normalReadingSpeed() {
        // 30 seconds per page is normal
        let result = engine.validatePageTurn(timeOnPage: 30.0)
        #expect(result == true)
    }
    
    @Test("Rejects too-fast page turns")
    func tooFastPageTurn() {
        // Less than 15 seconds is suspicious
        let result = engine.validatePageTurn(timeOnPage: 5.0)
        #expect(result == false)
    }
    
    @Test("Rejects excessive page rate")
    func excessivePageRate() {
        // More than 4 pages per minute is suspicious
        let result = engine.validatePageRate(pagesInLastMinute: 5)
        #expect(result == false)
    }
    
    @Test("Accepts normal page rate")
    func normalPageRate() {
        // 2 pages per minute is reasonable
        let result = engine.validatePageRate(pagesInLastMinute: 2)
        #expect(result == true)
    }
    
    @Test("Detects high scroll velocity")
    func highScrollVelocity() {
        // Very fast scrolling indicates skimming
        let result = engine.validateScrollVelocity(velocity: 5000.0)
        #expect(result == false)
    }
    
    @Test("Accepts normal scroll velocity")
    func normalScrollVelocity() {
        let result = engine.validateScrollVelocity(velocity: 500.0)
        #expect(result == true)
    }
    
    @Test("Calculates confidence score correctly")
    func confidenceScore() {
        // A session with all normal metrics should have high confidence
        let score = engine.calculateConfidence(
            averageTimePerPage: 45.0,
            averageScrollVelocity: 400.0,
            totalPagesRead: 10,
            sessionDuration: 450.0
        )
        #expect(score >= 0.8)
    }
    
    @Test("Low confidence for suspicious session")
    func lowConfidenceScore() {
        // Very fast reading with high scroll speed
        let score = engine.calculateConfidence(
            averageTimePerPage: 5.0,
            averageScrollVelocity: 4000.0,
            totalPagesRead: 50,
            sessionDuration: 120.0
        )
        #expect(score < 0.5)
    }
    
    @Test("Edge case: zero time on page")
    func zeroTimeOnPage() {
        let result = engine.validatePageTurn(timeOnPage: 0.0)
        #expect(result == false)
    }
    
    @Test("Edge case: negative values handled")
    func negativeValues() {
        let result = engine.validatePageTurn(timeOnPage: -1.0)
        #expect(result == false)
    }
}
