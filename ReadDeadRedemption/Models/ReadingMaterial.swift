import Foundation
import SwiftData

@Model
final class ReadingMaterial {
    var id: UUID
    var title: String
    var author: String
    var type: MaterialType
    var totalPages: Int
    var currentPage: Int
    var fileURL: String?
    var addedDate: Date
    var lastReadDate: Date?
    var isCompleted: Bool
    var coverImageData: Data?
    
    enum MaterialType: String, Codable, CaseIterable {
        case pdf = "PDF"
        case epub = "EPUB"
        case article = "Article"
        case webArticle = "Web Article"
        case textFile = "Text"
        
        var icon: String {
            switch self {
            case .pdf: return "doc.fill"
            case .epub: return "book.fill"
            case .article: return "doc.text.fill"
            case .webArticle: return "globe"
            case .textFile: return "text.alignleft"
            }
        }
    }
    
    init(
        title: String,
        author: String = "",
        type: MaterialType,
        totalPages: Int,
        fileURL: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.author = author
        self.type = type
        self.totalPages = totalPages
        self.currentPage = 0
        self.fileURL = fileURL
        self.addedDate = Date()
        self.lastReadDate = nil
        self.isCompleted = false
        self.coverImageData = nil
    }
    
    var progressPercentage: Double {
        guard totalPages > 0 else { return 0 }
        return Double(currentPage) / Double(totalPages)
    }
    
    var pagesRemaining: Int {
        max(0, totalPages - currentPage)
    }
}
