import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var showSubscription = false
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Reading Goal
                Section("Reading Goal") {
                    HStack {
                        Label("Daily Goal", systemImage: "target")
                        Spacer()
                        Text("\(appState.preferences.dailyPageGoal) pages")
                            .foregroundStyle(.secondary)
                    }
                    
                    Stepper("Pages: \(appState.preferences.dailyPageGoal)",
                            value: Binding(
                                get: { appState.preferences.dailyPageGoal },
                                set: { appState.preferences.dailyPageGoal = $0 }
                            ),
                            in: 1...100,
                            step: 5
                    )
                    
                    Picker("Goal Type", selection: Binding(
                        get: { appState.preferences.goalType },
                        set: { appState.preferences.goalType = $0 }
                    )) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                // App Blocking (requires paid Apple Developer account)
                Section("App Blocking") {
                    Text("Screen Time app blocking requires a paid Apple Developer account ($99/year).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Notifications
                Section("Notifications") {
                    Toggle("Daily Reminders", isOn: Binding(
                        get: { appState.preferences.notificationsEnabled },
                        set: { appState.preferences.notificationsEnabled = $0 }
                    ))
                    
                    Toggle("Streak Alerts", isOn: Binding(
                        get: { appState.preferences.streakNotifications },
                        set: { appState.preferences.streakNotifications = $0 }
                    ))
                    
                    Picker("Motivation Style", selection: Binding(
                        get: { appState.preferences.motivationStyle },
                        set: { appState.preferences.motivationStyle = $0 }
                    )) {
                        ForEach(MotivationStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                }
                
                // Premium
                Section("Premium") {
                    Button {
                        showSubscription = true
                    } label: {
                        HStack {
                            Label("Upgrade to Pro", systemImage: "crown.fill")
                                .foregroundStyle(.orange)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button("Restore Purchases") {
                        Task {
                            await appState.storeKitManager.restorePurchases()
                        }
                    }
                }
                
                // Data
                Section("Data") {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Reset All Progress", systemImage: "arrow.counterclockwise")
                            .foregroundStyle(.red)
                    }
                }
                
                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
            .alert("Reset Progress", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    // Reset logic handled by AppState
                }
            } message: {
                Text("This will permanently delete all reading progress, streaks, and achievements. This cannot be undone.")
            }
        }
    }
}
