import SwiftUI

// MARK: - Glass Card

struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Animated Button

struct AnimatedButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(title: String, icon: String? = nil, color: Color = .blue, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.white)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reading Progress Bar

struct ReadingProgressBar: View {
    let progress: Double
    var height: CGFloat = 8
    var backgroundColor: Color = .secondary.opacity(0.2)
    var foregroundColor: Color = .accent
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1))
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.6)
                    .offset(x: phase * geometry.size.width * 1.6 - geometry.size.width * 0.3)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
