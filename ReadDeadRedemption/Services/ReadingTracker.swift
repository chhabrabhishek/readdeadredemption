import Foundation
import PDFKit

/// Core reading tracker that monitors page changes and reading behavior
@Observable
final class ReadingTracker {
    static let shared = ReadingTracker()
    
    var isSessionActive: Bool = false
    var currentSession: ActiveSession?
    var pagesReadThisSession: Int = 0
    var sessionDuration: TimeInterval = 0
    
    private var timer: Timer?
    private var pageTimestamps: [Date] = []
    private var scrollVelocities: [Double] = []
    private let antiCheat = AntiCheatEngine.shared
    
    struct ActiveSession {
        let startTime: Date
        var currentPage: Int
        var startPage: Int
        var materialTitle: String
        var materialID: UUID?
        var pageTransitions: [(page: Int, timestamp: Date)]
        var idleIntervals: [TimeInterval]
        
        var pagesRead: Int {
            max(0, currentPage - startPage)
        }
        
        var duration: TimeInterval {
            Date().timeIntervalSince(startTime)
        }
    }
    
    private init() {}
    
    // MARK: - Session Management
    
    func startSession(materialTitle: String, materialID: UUID?, startPage: Int) {
        currentSession = ActiveSession(
            startTime: Date(),
            currentPage: startPage,
            startPage: startPage,
            materialTitle: materialTitle,
            materialID: materialID,
            pageTransitions: [(startPage, Date())],
            idleIntervals: []
        )
        isSessionActive = true
        pagesReadThisSession = 0
        pageTimestamps = [Date()]
        scrollVelocities = []
        
        startTimer()
    }
    
    func endSession() -> SessionResult? {
        guard let session = currentSession else { return nil }
        
        stopTimer()
        isSessionActive = false
        
        let validatedPages = antiCheat.validateSession(
            pagesRead: session.pagesRead,
            duration: session.duration,
            pageTimestamps: pageTimestamps,
            scrollVelocities: scrollVelocities
        )
        
        let result = SessionResult(
            pagesRead: validatedPages,
            totalDuration: session.duration,
            materialTitle: session.materialTitle,
            materialID: session.materialID,
            wasValid: validatedPages > 0,
            cheatingDetected: validatedPages < session.pagesRead
        )
        
        currentSession = nil
        pagesReadThisSession = 0
        
        return result
    }
    
    // MARK: - Page Tracking
    
    func recordPageChange(to page: Int) {
        guard var session = currentSession else { return }
        
        let now = Date()
        session.currentPage = page
        session.pageTransitions.append((page, now))
        pageTimestamps.append(now)
        
        currentSession = session
        
        // Calculate validated pages in real-time
        let validPages = antiCheat.validatePageTransition(
            from: session.pageTransitions,
            timestamps: pageTimestamps
        )
        pagesReadThisSession = validPages
    }
    
    func recordScrollVelocity(_ velocity: Double) {
        scrollVelocities.append(velocity)
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.sessionDuration = self.currentSession?.duration ?? 0
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        sessionDuration = 0
    }
    
    // MARK: - PDF Page Count
    
    func getPageCount(for url: URL) -> Int? {
        guard let document = PDFDocument(url: url) else { return nil }
        return document.pageCount
    }
}

// MARK: - Session Result

struct SessionResult {
    let pagesRead: Int
    let totalDuration: TimeInterval
    let materialTitle: String
    let materialID: UUID?
    let wasValid: Bool
    let cheatingDetected: Bool
    
    var formattedDuration: String {
        let minutes = Int(totalDuration) / 60
        let seconds = Int(totalDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
