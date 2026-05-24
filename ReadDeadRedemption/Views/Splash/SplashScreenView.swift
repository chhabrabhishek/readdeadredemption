import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var glowOpacity: Double = 0.4
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.05, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App icon with glow
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.blue.opacity(glowOpacity), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                    
                    // Icon
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                }
                
                // App name
                Text("ReadDead\nRedemption")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                // Tagline
                Text("Read to unlock your world")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.8
            }
        }
    }
}
