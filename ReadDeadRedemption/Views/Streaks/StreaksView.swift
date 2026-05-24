import SwiftUI
import SwiftData

struct StreaksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyProgress.date, order: .reverse) private var allProgress: [DailyProgress]
    @Query(sort: \Achievement.title) private var achievements: [Achievement]
    @State private var selectedTab: StreakTab = .streaks
    
    enum StreakTab: String, CaseIterable {
        case streaks = "Streaks"
        case achievements = "Achievements"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab picker
                Picker("", selection: $selectedTab) {
                    ForEach(StreakTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                ScrollView {
                    switch selectedTab {
                    case .streaks:
                        streaksContent
                    case .achievements:
                        achievementsContent
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Streaks & Rewards")
        }
    }
    
    // MARK: - Streaks Content
    
    private var streaksContent: some View {
        VStack(spacing: 20) {
            // Current streak
            VStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("\(currentStreak)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                
                Text("Day Streak")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)
            
            // Stats row
            HStack(spacing: 12) {
                StreakStatCard(title: "Longest", value: "\(longestStreak)", icon: "trophy.fill", color: .yellow)
                StreakStatCard(title: "Total XP", value: "\(totalXP)", icon: "star.fill", color: .purple)
                StreakStatCard(title: "Level", value: "\(level)", icon: "bolt.fill", color: .blue)
            }
            .padding(.horizontal)
            
            // Streak calendar
            VStack(alignment: .leading, spacing: 12) {
                Text("Last 30 Days")
                    .font(.headline)
                    .padding(.horizontal)
                
                streakCalendar
                    .padding(.horizontal)
            }
            
            // Milestones
            VStack(alignment: .leading, spacing: 12) {
                Text("Milestones")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(milestones, id: \.days) { milestone in
                    HStack(spacing: 12) {
                        Image(systemName: milestone.isComplete ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(milestone.isComplete ? .green : .secondary)
                        
                        Text("\(milestone.days)-day streak")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        if milestone.isComplete {
                            Text("✓")
                                .foregroundStyle(.green)
                        } else {
                            Text("\(max(0, milestone.days - currentStreak)) days left")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Achievements Content
    
    private var achievementsContent: some View {
        VStack(spacing: 16) {
            ForEach(Achievement.Category.allCases, id: \.self) { category in
                let categoryAchievements = achievements.filter { $0.category == category }
                if !categoryAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category.rawValue)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(categoryAchievements) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            if achievements.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Start reading to earn achievements!")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Streak Calendar
    
    private var streakCalendar: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(0..<30, id: \.self) { index in
                let date = Calendar.current.date(byAdding: .day, value: -(29 - index), to: Date())!
                let hasRead = allProgress.contains(where: {
                    Calendar.current.isDate($0.date, inSameDayAs: date) && $0.wasGoalMet
                })
                
                Circle()
                    .fill(hasRead ? Color.green : Color(.systemGray5))
                    .frame(height: 28)
                    .overlay {
                        if Calendar.current.isDateInToday(date) {
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 2)
                        }
                    }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Computed
    
    private var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = Date()
        
        for progress in allProgress {
            if calendar.isDate(progress.date, inSameDayAs: checkDate) && progress.wasGoalMet {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return streak
    }
    
    private var longestStreak: Int {
        var longest = 0
        var current = 0
        let sorted = allProgress.sorted { $0.date < $1.date }
        
        for progress in sorted {
            if progress.wasGoalMet {
                current += 1
                longest = max(longest, current)
            } else {
                current = 0
            }
        }
        return longest
    }
    
    private var totalXP: Int {
        allProgress.reduce(0) { $0 + $1.xpEarned }
    }
    
    private var level: Int {
        max(1, totalXP / 500 + 1)
    }
    
    private struct Milestone {
        let days: Int
        let isComplete: Bool
    }
    
    private var milestones: [Milestone] {
        [3, 7, 14, 30, 60, 100, 365].map {
            Milestone(days: $0, isComplete: longestStreak >= $0)
        }
    }
}

// MARK: - Supporting Views

struct StreakStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.iconName)
                .font(.title2)
                .foregroundStyle(achievement.isUnlocked ? .accent : .secondary)
                .frame(width: 44, height: 44)
                .background(
                    (achievement.isUnlocked ? Color.accentColor : Color.secondary).opacity(0.1),
                    in: Circle()
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.subheadline.weight(.medium))
                Text(achievement.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if !achievement.isUnlocked {
                    ProgressView(value: achievement.progress)
                        .tint(.accent)
                }
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Text("\(Int(achievement.progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
    }
}
