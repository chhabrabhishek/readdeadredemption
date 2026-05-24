import SwiftUI

/// GitHub-style reading heatmap showing daily reading intensity
struct HeatmapView: View {
    let progressData: [DailyProgress]
    
    private let columns = 15 // weeks to show
    private let rows = 7 // days per week
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Day labels
            HStack(spacing: 4) {
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(["", "M", "", "W", "", "F", ""], id: \.self) { label in
                        Text(label)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .frame(height: 12)
                    }
                }
                .frame(width: 12)
                
                // Grid
                LazyHGrid(rows: Array(repeating: GridItem(.fixed(12), spacing: 4), count: rows), spacing: 4) {
                    ForEach(0..<(columns * rows), id: \.self) { index in
                        let date = dateForIndex(index)
                        let pages = pagesForDate(date)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colorForPages(pages))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            
            // Legend
            HStack(spacing: 4) {
                Text("Less")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                
                ForEach(0..<5) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForLevel(level))
                        .frame(width: 10, height: 10)
                }
                
                Text("More")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Helpers
    
    private func dateForIndex(_ index: Int) -> Date {
        let totalDays = columns * rows
        let daysAgo = totalDays - 1 - index
        return Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }
    
    private func pagesForDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        return progressData.first(where: {
            calendar.isDate($0.date, inSameDayAs: date)
        })?.pagesRead ?? 0
    }
    
    private func colorForPages(_ pages: Int) -> Color {
        switch pages {
        case 0: return Color(.systemGray5)
        case 1...5: return Color.green.opacity(0.3)
        case 6...15: return Color.green.opacity(0.5)
        case 16...30: return Color.green.opacity(0.7)
        default: return Color.green
        }
    }
    
    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0: return Color(.systemGray5)
        case 1: return Color.green.opacity(0.3)
        case 2: return Color.green.opacity(0.5)
        case 3: return Color.green.opacity(0.7)
        default: return Color.green
        }
    }
}
