import SwiftUI

struct AppSelectionView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "apps.iphone")
                        .font(.system(size: 48))
                        .foregroundStyle(.accent)
                    
                    Text("App Blocking")
                        .font(.title2.weight(.bold))
                    
                    Text("App blocking requires a paid Apple Developer account. For now, use this app as a reading tracker and motivator!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Image(systemName: "lock.shield")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary.opacity(0.3))
                
                Spacer()
                
                Button {
                    appState.completeOnboarding()
                } label: {
                    Text("Continue Without Blocking")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.accent, in: RoundedRectangle(cornerRadius: 14))
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationTitle("App Selection")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
