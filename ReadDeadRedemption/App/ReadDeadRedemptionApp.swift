import SwiftUI
import SwiftData

@main
struct ReadDeadRedemptionApp: App {
    @State private var appState = AppState()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ReadingSession.self,
            DailyProgress.self,
            UserPreferences.self,
            Achievement.self,
            ReadingMaterial.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .modelContainer(sharedModelContainer)
                .task {
                    await appState.initialize()
                }
        }
    }
}
