import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var selectedPlan: SubscriptionPlan = .monthly
    @State private var isPurchasing = false
    
    enum SubscriptionPlan: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"
        case lifetime = "Lifetime"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("ReadDeadRedemption Pro")
                            .font(.title.weight(.bold))
                        
                        Text("Unlock the full reading experience")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 24)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        ProFeatureRow(icon: "infinity", title: "Unlimited Blocked Apps", description: "Block any number of distracting apps")
                        ProFeatureRow(icon: "chart.xyaxis.line", title: "Advanced Analytics", description: "Detailed reading insights and trends")
                        ProFeatureRow(icon: "timer", title: "Focus Sessions", description: "Pomodoro-style reading timer")
                        ProFeatureRow(icon: "widget.small", title: "Home Screen Widget", description: "Track progress at a glance")
                        ProFeatureRow(icon: "paintbrush.fill", title: "Custom Themes", description: "Personalize your reading experience")
                        ProFeatureRow(icon: "icloud.fill", title: "Cloud Sync", description: "Sync progress across all devices")
                    }
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    
                    // Pricing cards
                    VStack(spacing: 12) {
                        ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                            PricingCard(
                                plan: plan,
                                isSelected: selectedPlan == plan,
                                onTap: { selectedPlan = plan }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Purchase button
                    Button(action: purchase) {
                        Group {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Subscribe Now")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .foregroundStyle(.white)
                    }
                    .disabled(isPurchasing)
                    .padding(.horizontal)
                    
                    // Legal
                    Text("Cancel anytime. Subscription auto-renews unless cancelled 24 hours before the end of the current period.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    private func purchase() {
        isPurchasing = true
        Task {
            let productID: String
            switch selectedPlan {
            case .monthly: productID = "com.yourcompany.readdeadredemption.monthly"
            case .yearly: productID = "com.yourcompany.readdeadredemption.yearly"
            case .lifetime: productID = "com.yourcompany.readdeadredemption.lifetime"
            }
            
            await appState.storeKitManager.purchase(productID: productID)
            isPurchasing = false
            dismiss()
        }
    }
}

// MARK: - Pro Feature Row

struct ProFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Pricing Card

struct PricingCard: View {
    let plan: SubscriptionView.SubscriptionPlan
    let isSelected: Bool
    let onTap: () -> Void
    
    var price: String {
        switch plan {
        case .monthly: return "$4.99/mo"
        case .yearly: return "$29.99/yr"
        case .lifetime: return "$79.99"
        }
    }
    
    var savings: String? {
        switch plan {
        case .monthly: return nil
        case .yearly: return "Save 50%"
        case .lifetime: return "Best Value"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.rawValue)
                            .font(.headline)
                        
                        if let savings {
                            Text(savings)
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.orange.opacity(0.2), in: Capsule())
                                .foregroundStyle(.orange)
                        }
                    }
                    
                    Text(price)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .orange : .secondary)
                    .font(.title3)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.orange : .clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
