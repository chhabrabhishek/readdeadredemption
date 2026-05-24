import SwiftUI
import FamilyControls

struct AppSelectionView: View {
    @Environment(AppState.self) private var appState
    @State private var selection = FamilyActivitySelection()
    @State private var isPickerPresented = false
    
    private let screenTimeManager = ScreenTimeManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "apps.iphone")
                        .font(.system(size: 48))
                        .foregroundStyle(.accent)
                    
                    Text("Select Apps to Block")
                        .font(.title2.weight(.bold))
                    
                    Text("Choose which apps you want locked until you complete your reading goal.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                
                // Selected count
                if !selection.applicationTokens.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("\(selection.applicationTokens.count) apps selected")
                            .font(.subheadline.weight(.medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.green.opacity(0.1), in: Capsule())
                }
                
                Spacer()
                
                // Select button
                Button {
                    isPickerPresented = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                        Text(selection.applicationTokens.isEmpty ? "Choose Apps" : "Change Selection")
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.accent, in: RoundedRectangle(cornerRadius: 14))
                }
                
                // Save button
                if !selection.applicationTokens.isEmpty {
                    Button {
                        saveAndBlock()
                    } label: {
                        Text("Save & Activate Blocking")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.red, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .familyActivityPicker(
                isPresented: $isPickerPresented,
                selection: $selection
            )
            .navigationTitle("App Selection")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func saveAndBlock() {
        screenTimeManager.activitySelection = selection
        Task {
            await screenTimeManager.lockApps()
        }
    }
}
