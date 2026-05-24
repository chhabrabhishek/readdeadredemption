import SwiftUI

struct FocusSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phase: FocusPhase = .setup
    @State private var focusMinutes: Double = 25
    @State private var breakMinutes: Double = 5
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer?
    @State private var totalFocusTime: Int = 0
    @State private var sessionsCompleted: Int = 0
    
    enum FocusPhase {
        case setup
        case reading
        case breakTime
        case complete
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                switch phase {
                case .setup:
                    setupView
                case .reading:
                    timerView(title: "Focus Time", color: .blue)
                case .breakTime:
                    timerView(title: "Break Time", color: .green)
                case .complete:
                    completeView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        timer?.invalidate()
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: phase == .reading ? [.blue.opacity(0.1), .purple.opacity(0.05)] :
                    phase == .breakTime ? [.green.opacity(0.1), .mint.opacity(0.05)] :
                    [.clear, .clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Setup View
    
    private var setupView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.system(size: 56))
                    .foregroundStyle(.blue)
                
                Text("Focus Session")
                    .font(.title.weight(.bold))
                
                Text("Set your reading focus and break times")
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 20) {
                // Focus time slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Focus Time")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(focusMinutes)) min")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                    
                    Slider(value: $focusMinutes, in: 5...60, step: 5)
                        .tint(.blue)
                }
                
                // Break time slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Break Time")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(breakMinutes)) min")
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                    
                    Slider(value: $breakMinutes, in: 1...15, step: 1)
                        .tint(.green)
                }
            }
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
            
            Button(action: startFocusSession) {
                Text("Start Focus Session")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Timer View
    
    private func timerView(title: String, color: Color) -> some View {
        VStack(spacing: 32) {
            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(color)
            
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 12)
                    .frame(width: 220, height: 220)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timeRemaining)
                
                VStack(spacing: 4) {
                    Text(formattedTime)
                        .font(.system(size: 48, weight: .light, design: .monospaced))
                    
                    Text("remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 24) {
                Button(action: {
                    timer?.invalidate()
                    phase = .complete
                }) {
                    Label("End", systemImage: "stop.fill")
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.red.opacity(0.1), in: Capsule())
                        .foregroundStyle(.red)
                }
                
                if phase == .reading {
                    Button(action: skipToBreak) {
                        Label("Break", systemImage: "forward.fill")
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(color.opacity(0.1), in: Capsule())
                            .foregroundStyle(color)
                    }
                }
            }
            
            Text("Session \(sessionsCompleted + 1)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Complete View
    
    private var completeView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            
            Text("Session Complete!")
                .font(.title.weight(.bold))
            
            VStack(spacing: 12) {
                HStack {
                    Label("Total Focus", systemImage: "brain.head.profile")
                    Spacer()
                    Text("\(totalFocusTime / 60) min")
                        .fontWeight(.semibold)
                }
                
                Divider()
                
                HStack {
                    Label("Sessions", systemImage: "repeat")
                    Spacer()
                    Text("\(sessionsCompleted)")
                        .fontWeight(.semibold)
                }
            }
            .padding(20)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            
            Button("Done") {
                dismiss()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Logic
    
    private var progress: CGFloat {
        let total = phase == .reading ? Int(focusMinutes) * 60 : Int(breakMinutes) * 60
        guard total > 0 else { return 0 }
        return CGFloat(total - timeRemaining) / CGFloat(total)
    }
    
    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startFocusSession() {
        timeRemaining = Int(focusMinutes) * 60
        phase = .reading
        startTimer()
    }
    
    private func skipToBreak() {
        timer?.invalidate()
        totalFocusTime += Int(focusMinutes) * 60 - timeRemaining
        sessionsCompleted += 1
        startBreak()
    }
    
    private func startBreak() {
        timeRemaining = Int(breakMinutes) * 60
        phase = .breakTime
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                handleTimerComplete()
            }
        }
    }
    
    private func handleTimerComplete() {
        switch phase {
        case .reading:
            totalFocusTime += Int(focusMinutes) * 60
            sessionsCompleted += 1
            startBreak()
        case .breakTime:
            // Start another focus session
            startFocusSession()
        default:
            break
        }
    }
}
