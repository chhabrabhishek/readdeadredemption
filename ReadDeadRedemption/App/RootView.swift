import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Group {
            if !appState.isOnboardingComplete {
                OnboardingView()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.isOnboardingComplete)
    }
}

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        @Bindable var state = appState
        
        TabView(selection: $state.currentTab) {
            Tab("Dashboard", systemImage: "house.fill", value: .dashboard) {
                DashboardView()
            }
            
            Tab("Read", systemImage: "book.fill", value: .reading) {
                ReadingSessionView()
            }
            
            Tab("Analytics", systemImage: "chart.bar.fill", value: .analytics) {
                AnalyticsView()
            }
            
            Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                SettingsView()
            }
        }
        .tint(Color.blue)
    }
}
