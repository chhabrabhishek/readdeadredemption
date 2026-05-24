import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Custom shield UI shown when a blocked app is opened
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        let pagesRemaining = getPagesRemaining()
        
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0),
            icon: UIImage(systemName: "book.closed.fill"),
            title: ShieldConfiguration.Label(
                text: "App Blocked",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Read \(pagesRemaining) more page\(pagesRemaining == 1 ? "" : "s") to unlock",
                color: UIColor.white.withAlphaComponent(0.7)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open ReadDeadRedemption",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Close App",
                color: UIColor.white.withAlphaComponent(0.5)
            )
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        configuration(shielding: application)
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        let pagesRemaining = getPagesRemaining()
        
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0),
            icon: UIImage(systemName: "book.closed.fill"),
            title: ShieldConfiguration.Label(
                text: "Site Blocked",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Read \(pagesRemaining) more page\(pagesRemaining == 1 ? "" : "s") to unlock",
                color: UIColor.white.withAlphaComponent(0.7)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open ReadDeadRedemption",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Close",
                color: UIColor.white.withAlphaComponent(0.5)
            )
        )
    }
    
    // MARK: - Helpers
    
    private func getPagesRemaining() -> Int {
        let defaults = UserDefaults(suiteName: "group.com.yourcompany.readdeadredemption")
        let goal = defaults?.integer(forKey: "dailyPageGoal") ?? 20
        let read = defaults?.integer(forKey: "todayPagesRead") ?? 0
        return max(0, goal - read)
    }
}
