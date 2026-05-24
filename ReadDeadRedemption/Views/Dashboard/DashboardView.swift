import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyProgress.date, order: .reverse) private var recentProgress: [DailyProgress]
    @State private var showAppSelection = false
    @State private var animateRing = false
    
    private let screenTimeManager = ScreenTimeManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Main progress card
                    progressCard
                    
                    // Quick actions
                    quickActions
                    
                    // Status cards
                    statusGrid
                    
                    // Today's sessions
                    todaySessions
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("ReadDeadRedemption")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAppSelection = true
                    } label: {
                        Image(systemName: "apps.iphone")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showAppSelection) {
                AppSelectionView()
            }
        }
    }
    
    // MARK: - Progress Card
    
    private var progressCard: some View {
        VStack(spacing: 20) {
            // Progress ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.accent.opacity(0.15), lineWidth: 16)
                    .frame(width: 180, height: 180)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: animateRing ? progressPercentage : 0)
                    .stroke(
                        AngularGradient(
                            colors: [.accent, .accent.opacity(0.6), .accent],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                
                // Center content
                VStack(spacing: 4) {
                    Text("\(appState.dailyProgress)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                    
                    Text("of \(appState.dailyGoal) pages")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                    animateRing = true
                }
            }
            
            // Status text
            VStack(spacing: 4) {
                if appState.isUnlocked {
                    Label("Apps Unlocked", systemImage: "lock.open.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                } else {
                    Label("\(appState.dailyGoal - appState.dailyProgress) pages to unlock", systemImage: "lock.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
    }
    
    // MARK: - Quick Actions
    
    private var quickActions: some View {
        HStack(spacing: 12) {
            NavigationLink {
                ReadingSessionView()
            } label: {
                quickActionButton(
                    icon: "book.fill",
                    title: "Start Reading",
                    color: .accent
                )
            }
            
            NavigationLink {
                FocusSessionView()
            } label: {
                quickActionButton(
                    icon: "brain.fill",
                    title: "Focus Mode",
                    color: .purple
                )
            }
        }
    }
    
    private func quickActionButton(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(color)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Status Grid
    
    private var statusGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                title: "Streak",
                value: "\(currentStreak)",
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "Blocked",
                value: "\(screenTimeManager.blockedAppsCount)",
                icon: "lock.fill",
                color: .red
            )
            
            StatCard(
                title: "Today",
                value: formattedReadingTime,
                icon: "clock.fill",
                color: .blue
            )
            
            StatCard(
                title: "Level",
                value: "\(currentLevel)",
                icon: "star.fill",
                color: .yellow
            )
        }
    }
    
    // MARK: - Today's Sessions
    
    private var todaySessions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Reading")
                .font(.headline)
            
            if recentProgress.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "book.closed")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text("No reading sessions yet today")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 24)
            } else if let today = recentProgress.first {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(today.pagesRead) pages read")
                            .font(.subheadline.weight(.medium))
                        Text("\(today.sessionsCount) sessions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if today.wasGoalMet {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var progressPercentage: CGFloat {
        guard appState.dailyGoal > 0 else { return 0 }
        return min(CGFloat(appState.dailyProgress) / CGFloat(appState.dailyGoal), 1.0)
    }
    
    private var currentStreak: Int {
        recentProgress.first?.streakDay ?? 0
    }
    
    private var currentLevel: Int {
        let totalXP = recentProgress.reduce(0) { $0 + $1.xpEarned }
        return max(1, totalXP / 500 + 1)
    }
    
    private var formattedReadingTime: String {
        guard let today = recentProgress.first else { return "0m" }
        let minutes = Int(today.totalReadingTime / 60)
        return "\(minutes)m"
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2.weight(.bold))
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}
