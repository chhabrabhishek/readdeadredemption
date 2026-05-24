import SwiftUI

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - Theme Colors
    
    static let deepBlue = Color(hex: "1a1a2e")
    static let accentPurple = Color(hex: "6c63ff")
    static let softGreen = Color(hex: "4ecdc4")
    static let warmOrange = Color(hex: "ff6b35")
    static let deepPurple = Color(hex: "2d1b69")
    static let neonBlue = Color(hex: "00d4ff")
}

// MARK: - View Extensions

extension View {
    func cardStyle(padding: CGFloat = 16, cornerRadius: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    func glow(color: Color = .blue, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color.opacity(0.5), radius: radius / 2)
            .shadow(color: color.opacity(0.3), radius: radius)
    }
    
    func animateOnAppear(delay: Double = 0) -> some View {
        modifier(AnimateOnAppearModifier(delay: delay))
    }
}

struct AnimateOnAppearModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Date Extensions

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    var daysAgo: Int {
        Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }
    
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - Int Extensions

extension Int {
    var formattedWithSuffix: String {
        if self >= 1000000 {
            return String(format: "%.1fM", Double(self) / 1000000)
        } else if self >= 1000 {
            return String(format: "%.1fK", Double(self) / 1000)
        }
        return "\(self)"
    }
}
