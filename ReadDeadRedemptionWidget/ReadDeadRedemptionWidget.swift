import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct ReadingProgressProvider: TimelineProvider {
    func placeholder(in context: Context) -> ReadingProgressEntry {
        ReadingProgressEntry(date: Date(), pagesRead: 12, pageGoal: 20, streak: 5, isUnlocked: false)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ReadingProgressEntry) -> Void) {
        let entry = ReadingProgressEntry(date: Date(), pagesRead: 12, pageGoal: 20, streak: 5, isUnlocked: false)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ReadingProgressEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.yourcompany.readdeadredemption")
        let pagesRead = defaults?.integer(forKey: "todayPagesRead") ?? 0
        let pageGoal = defaults?.integer(forKey: "dailyPageGoal") ?? 20
        let streak = defaults?.integer(forKey: "currentStreak") ?? 0
        let isUnlocked = defaults?.bool(forKey: "goalMetToday") ?? false
        
        let entry = ReadingProgressEntry(
            date: Date(),
            pagesRead: pagesRead,
            pageGoal: pageGoal,
            streak: streak,
            isUnlocked: isUnlocked
        )
        
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Entry

struct ReadingProgressEntry: TimelineEntry {
    let date: Date
    let pagesRead: Int
    let pageGoal: Int
    let streak: Int
    let isUnlocked: Bool
    
    var progress: Double {
        guard pageGoal > 0 else { return 0 }
        return min(Double(pagesRead) / Double(pageGoal), 1.0)
    }
}

// MARK: - Widget Views

struct SmallWidgetView: View {
    let entry: ReadingProgressEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 6)
                
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(entry.isUnlocked ? Color.green : Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Image(systemName: entry.isUnlocked ? "lock.open.fill" : "lock.fill")
                        .font(.caption)
                        .foregroundStyle(entry.isUnlocked ? .green : .blue)
                    
                    Text("\(entry.pagesRead)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
            .frame(width: 60, height: 60)
            
            Text("\(entry.pagesRead)/\(entry.pageGoal) pages")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            if entry.streak > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.orange)
                    Text("\(entry.streak)")
                        .font(.system(size: 10, weight: .semibold))
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct MediumWidgetView: View {
    let entry: ReadingProgressEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Progress ring
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(entry.isUnlocked ? Color.green : Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Image(systemName: entry.isUnlocked ? "lock.open.fill" : "lock.fill")
                        .font(.caption)
                        .foregroundStyle(entry.isUnlocked ? .green : .blue)
                    
                    Text("\(Int(entry.progress * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
            }
            .frame(width: 80, height: 80)
            
            // Right: Stats
            VStack(alignment: .leading, spacing: 6) {
                Text("ReadDeadRedemption")
                    .font(.caption.weight(.semibold))
                
                Text("\(entry.pagesRead) of \(entry.pageGoal) pages")
                    .font(.subheadline)
                
                HStack(spacing: 12) {
                    Label("\(entry.streak)", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    
                    Text(entry.isUnlocked ? "Unlocked" : "Locked")
                        .font(.caption)
                        .foregroundStyle(entry.isUnlocked ? .green : .red)
                }
                
                if !entry.isUnlocked {
                    Text("\(entry.pageGoal - entry.pagesRead) pages to unlock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Definition

struct ReadDeadRedemptionWidget: Widget {
    let kind: String = "ReadDeadRedemptionWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ReadingProgressProvider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetEntryView(entry: entry)
            } else {
                WidgetEntryView(entry: entry)
                    .padding()
            }
        }
        .configurationDisplayName("Reading Progress")
        .description("Track your daily reading progress and unlock status.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: ReadingProgressEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle

@main
struct ReadDeadRedemptionWidgetBundle: WidgetBundle {
    var body: some Widget {
        ReadDeadRedemptionWidget()
    }
}
