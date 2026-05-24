import Foundation
import SwiftData

@Model
final class ReadingSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var pagesRead: Int
    var duration: TimeInterval
    var materialID: UUID?
    var materialTitle: String
    var averagePageTime: TimeInterval
    var scrollVelocities: [Double]
    var wasValidated: Bool
    var cheatingDetected: Bool
    
    init(
        materialTitle: String,
        materialID: UUID? = nil
    ) {
        self.id = UUID()
        self.startTime = Date()
        self.endTime = nil
        self.pagesRead = 0
        self.duration = 0
        self.materialID = materialID
        self.materialTitle = materialTitle
        self.averagePageTime = 0
        self.scrollVelocities = []
        self.wasValidated = false
        self.cheatingDetected = false
    }
    
    func finalize() {
        self.endTime = Date()
        self.duration = (endTime ?? Date()).timeIntervalSince(startTime)
        if pagesRead > 0 {
            self.averagePageTime = duration / Double(pagesRead)
        }
    }
}
