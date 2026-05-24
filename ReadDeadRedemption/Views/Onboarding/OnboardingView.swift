import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0
    @State private var dailyGoal = 20
    @State private var goalType: GoalType = .pages
    @State private var motivationStyle: MotivationStyle = .balanced
    
    private let totalPages = 5
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: currentPage)
            
            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 32 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Content
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)
                    
                    GoalSetupPage(dailyGoal: $dailyGoal, goalType: $goalType)
                        .tag(1)
                    
                    MotivationPage(style: $motivationStyle)
                        .tag(2)
                    
                    AppBlockingExplanationPage()
                        .tag(3)
                    
                    PermissionPage()
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button {
                            withAnimation { currentPage -= 1 }
                        } label: {
                            Text("Back")
                                .font(.body.weight(.medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        if currentPage < totalPages - 1 {
                            withAnimation(.spring(response: 0.4)) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(currentPage == totalPages - 1 ? "Get Started" : "Continue")
                                .font(.body.weight(.semibold))
                            Image(systemName: "arrow.right")
                                .font(.body.weight(.semibold))
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 16)
                        .background(.white, in: Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var gradientColors: [Color] {
        switch currentPage {
        case 0: return [Color(hex: "1a1a2e"), Color(hex: "16213e")]
        case 1: return [Color(hex: "0f3460"), Color(hex: "1a1a2e")]
        case 2: return [Color(hex: "533483"), Color(hex: "0f3460")]
        case 3: return [Color(hex: "e94560"), Color(hex: "533483")]
        case 4: return [Color(hex: "0f3460"), Color(hex: "1a1a2e")]
        default: return [Color(hex: "1a1a2e"), Color(hex: "16213e")]
        }
    }
    
    private func completeOnboarding() {
        let defaults = UserDefaults(suiteName: "group.com.yourcompany.readdeadredemption")
        defaults?.set(dailyGoal, forKey: "dailyGoal")
        defaults?.set(goalType.rawValue, forKey: "goalType")
        defaults?.set(motivationStyle.rawValue, forKey: "motivationStyle")
        
        appState.dailyGoal = dailyGoal
        appState.completeOnboarding()
    }
}

// MARK: - Welcome Page

private struct WelcomePage: View {
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "book.closed.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white)
                .scaleEffect(animate ? 1.0 : 0.5)
                .opacity(animate ? 1.0 : 0)
            
            VStack(spacing: 12) {
                Text("ReadDeadRedemption")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Read more. Scroll less.")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("Block distracting apps until you complete\nyour daily reading goal.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
}

// MARK: - Goal Setup Page

private struct GoalSetupPage: View {
    @Binding var dailyGoal: Int
    @Binding var goalType: GoalType
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Set Your Daily Goal")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                
                Text("How much would you like to read each day?")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            // Goal type picker
            HStack(spacing: 12) {
                ForEach(GoalType.allCases, id: \.self) { type in
                    Button {
                        withAnimation { goalType = type }
                    } label: {
                        Text(type.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(goalType == type ? .black : .white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(goalType == type ? .white : .white.opacity(0.15))
                            )
                    }
                }
            }
            
            // Goal value
            VStack(spacing: 8) {
                Text("\(dailyGoal)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                
                Text(goalType == .pages ? "pages per day" : "minutes per day")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            // Stepper
            HStack(spacing: 24) {
                Button {
                    withAnimation { dailyGoal = max(5, dailyGoal - 5) }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Slider(value: Binding(
                    get: { Double(dailyGoal) },
                    set: { dailyGoal = Int($0) }
                ), in: 5...100, step: 5)
                .tint(.white)
                
                Button {
                    withAnimation { dailyGoal = min(100, dailyGoal + 5) }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Motivation Style Page

private struct MotivationPage: View {
    @Binding var style: MotivationStyle
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Your Motivation Style")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                
                Text("How strict should ReadDeadRedemption be?")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            VStack(spacing: 16) {
                ForEach(MotivationStyle.allCases, id: \.self) { option in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            style = option
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: option.icon)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(.white.opacity(0.1), in: Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.rawValue)
                                    .font(.headline)
                                Text(option.description)
                                    .font(.caption)
                                    .opacity(0.7)
                            }
                            
                            Spacer()
                            
                            Image(systemName: style == option ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundStyle(style == option ? .white : .white.opacity(0.3))
                        }
                        .foregroundStyle(.white)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(style == option ? .white.opacity(0.15) : .white.opacity(0.05))
                                .stroke(style == option ? .white.opacity(0.3) : .clear, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - App Blocking Explanation

private struct AppBlockingExplanationPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white)
            
            VStack(spacing: 12) {
                Text("How App Blocking Works")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                
                Text("ReadDeadRedemption uses Apple's Screen Time API to temporarily restrict access to apps you choose.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "hand.raised.fill", text: "You choose which apps to block")
                FeatureRow(icon: "book.fill", text: "Read your daily goal to unlock")
                FeatureRow(icon: "lock.open.fill", text: "Apps unlock after you finish reading")
                FeatureRow(icon: "shield.checkered", text: "Your data stays private on-device")
            }
            .padding(.horizontal, 24)
            
            Spacer()
            Spacer()
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.body)
                .frame(width: 32)
                .foregroundStyle(.white.opacity(0.8))
            
            Text(text)
                .font(.body)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}

// MARK: - Permission Page

private struct PermissionPage: View {
    @Environment(AppState.self) private var appState
    @State private var permissionGranted = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: permissionGranted ? "checkmark.shield.fill" : "shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(permissionGranted ? .green : .white)
                .contentTransition(.symbolEffect(.replace))
            
            VStack(spacing: 12) {
                Text("Screen Time Permission")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                
                Text("ReadDeadRedemption needs Screen Time access to block and unblock apps. This data never leaves your device.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            if !permissionGranted {
                Button {
                    Task {
                        await appState.checkAuthorization()
                        withAnimation {
                            permissionGranted = appState.isAuthorized
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "lock.shield")
                        Text("Grant Permission")
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(.white, in: Capsule())
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Permission Granted")
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.green)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal)
    }
}
