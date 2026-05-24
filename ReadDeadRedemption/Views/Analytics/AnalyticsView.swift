import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyProgress.date, order: .reverse) private var allProgress: [DailyProgress]
    @Query(sort: \ReadingSession.startTime, order: .reverse) private var sessions: [ReadingSession]
    @State private var selectedTimeframe: Timeframe = .week
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Timeframe picker
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases, id: \.self) { frame in
                            Text(frame.rawValue).tag(frame)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Summary cards
                    summaryCards
                    
                    // Reading heatmap
                    heatmapSection
                    
                    // Weekly chart
                    weeklyChart
                    
                    // Recent sessions
                    recentSessions
                }
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Analytics")
        }
    }
    
    // MARK: - Summary Cards
    
    private var summaryCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            AnalyticCard(
                title: "Total Pages",
                value: "\(totalPages)",
                icon: "book.fill",
                color: .blue
            )
            
            AnalyticCard(
                title: "Avg/Day",
                value: "\(averagePagesPerDay)",
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )
            
            AnalyticCard(
                title: "Sessions",
                value: "\(filteredSessions.count)",
                icon: "clock.fill",
                color: .purple
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Heatmap
    
    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reading Heatmap")
                .font(.headline)
                .padding(.horizontal)
            
            HeatmapView(progressData: allProgress)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Weekly Chart
    
    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weekData, id: \.day) { data in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(data.pages > 0 ? Color.blue : Color.blue.opacity(0.15))
                            .frame(height: max(4, CGFloat(data.pages) / CGFloat(max(maxWeekPages, 1)) * 120))
                        
                        Text(data.dayLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
            .padding(.horizontal)
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
    
    // MARK: - Recent Sessions
    
    private var recentSessions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(filteredSessions.prefix(10)) { session in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.materialTitle)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                        
                        Text("\(session.pagesRead) pages • \(formattedDuration(session.duration))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(session.startTime, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredProgress: [DailyProgress] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeframe {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return allProgress.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return allProgress.filter { $0.date >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            return allProgress.filter { $0.date >= yearAgo }
        }
    }
    
    private var filteredSessions: [ReadingSession] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeframe {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return sessions.filter { $0.startTime >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return sessions.filter { $0.startTime >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            return sessions.filter { $0.startTime >= yearAgo }
        }
    }
    
    private var totalPages: Int {
        filteredProgress.reduce(0) { $0 + $1.pagesRead }
    }
    
    private var averagePagesPerDay: Int {
        guard !filteredProgress.isEmpty else { return 0 }
        return totalPages / filteredProgress.count
    }
    
    private struct WeekDayData {
        let day: Int
        let dayLabel: String
        let pages: Int
    }
    
    private var weekData: [WeekDayData] {
        let calendar = Calendar.current
        let today = Date()
        let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
        
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -(6 - offset), to: today)!
            let pages = allProgress.first(where: {
                calendar.isDate($0.date, inSameDayAs: date)
            })?.pagesRead ?? 0
            
            let weekday = (calendar.component(.weekday, from: date) + 5) % 7
            return WeekDayData(day: offset, dayLabel: dayLabels[weekday], pages: pages)
        }
    }
    
    private var maxWeekPages: Int {
        weekData.map(\.pages).max() ?? 1
    }
    
    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes)m"
        }
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}

// MARK: - Analytic Card

struct AnalyticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title3.weight(.bold))
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}
