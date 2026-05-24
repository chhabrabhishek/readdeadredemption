import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ReadingSessionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var showDocumentPicker = false
    @State private var selectedPDFURL: URL?
    @State private var isReading = false
    @State private var showSessionComplete = false
    @State private var sessionResult: SessionResult?
    
    private let tracker = ReadingTracker.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                if isReading, let url = selectedPDFURL {
                    PDFReaderView(
                        url: url,
                        onPageChange: { page in
                            tracker.recordPageChange(to: page)
                        },
                        onScrollVelocity: { velocity in
                            tracker.recordScrollVelocity(velocity)
                        }
                    )
                    .overlay(alignment: .bottom) {
                        readingOverlay
                    }
                } else {
                    emptyState
                }
            }
            .navigationTitle("Read")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isReading {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("End Session") {
                            endSession()
                        }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.red)
                    }
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPickerView { url in
                    selectedPDFURL = url
                    startSession(with: url)
                }
            }
            .sheet(isPresented: $showSessionComplete) {
                if let result = sessionResult {
                    SessionCompleteView(result: result)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "doc.text.fill")
                .font(.system(size: 64))
                .foregroundStyle(.accent.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("Start Reading")
                    .font(.title2.weight(.bold))
                
                Text("Import a PDF, EPUB, or document to begin your reading session.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 12) {
                Button {
                    showDocumentPicker = true
                } label: {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text("Import Document")
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.accent, in: RoundedRectangle(cornerRadius: 14))
                }
                
                // Quick read option with sample
                Button {
                    startQuickRead()
                } label: {
                    HStack {
                        Image(systemName: "text.page.fill")
                        Text("Quick Read (Sample Text)")
                    }
                    .font(.body.weight(.medium))
                    .foregroundStyle(.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 24)
            
            // Progress reminder
            if !appState.isUnlocked {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.orange)
                    Text("\(appState.dailyGoal - appState.dailyProgress) pages left to unlock apps")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(.orange.opacity(0.1), in: Capsule())
            }
            
            Spacer()
        }
    }
    
    // MARK: - Reading Overlay
    
    private var readingOverlay: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(tracker.pagesReadThisSession) pages")
                    .font(.headline)
                    .contentTransition(.numericText())
                
                Text(formattedSessionTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Progress toward goal
            CircularProgressView(
                progress: sessionProgress,
                lineWidth: 4,
                size: 40
            )
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }
    
    // MARK: - Actions
    
    private func startSession(with url: URL) {
        let pageCount = tracker.getPageCount(for: url) ?? 0
        tracker.startSession(
            materialTitle: url.lastPathComponent,
            materialID: nil,
            startPage: 0
        )
        isReading = true
    }
    
    private func startQuickRead() {
        // For demo/testing purposes
        tracker.startSession(
            materialTitle: "Quick Read",
            materialID: nil,
            startPage: 0
        )
        isReading = true
        selectedPDFURL = Bundle.main.url(forResource: "sample", withExtension: "pdf")
    }
    
    private func endSession() {
        guard let result = tracker.endSession() else { return }
        sessionResult = result
        isReading = false
        
        if result.wasValid && result.pagesRead > 0 {
            appState.recordPagesRead(result.pagesRead)
            saveSession(result)
        }
        
        showSessionComplete = true
    }
    
    private func saveSession(_ result: SessionResult) {
        let session = ReadingSession(materialTitle: result.materialTitle, materialID: result.materialID)
        session.pagesRead = result.pagesRead
        session.duration = result.totalDuration
        session.wasValidated = result.wasValid
        session.cheatingDetected = result.cheatingDetected
        session.finalize()
        
        modelContext.insert(session)
        try? modelContext.save()
    }
    
    // MARK: - Computed
    
    private var formattedSessionTime: String {
        let minutes = Int(tracker.sessionDuration) / 60
        let seconds = Int(tracker.sessionDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var sessionProgress: Double {
        guard appState.dailyGoal > 0 else { return 0 }
        return Double(tracker.pagesReadThisSession) / Double(appState.dailyGoal - appState.dailyProgress)
    }
}

// MARK: - Circular Progress View

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.accentColor.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Session Complete View

struct SessionCompleteView: View {
    let result: SessionResult
    @Environment(\.dismiss) private var dismiss
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Celebration
            Image(systemName: result.wasValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 72))
                .foregroundStyle(result.wasValid ? .green : .orange)
                .scaleEffect(animate ? 1.0 : 0.5)
            
            VStack(spacing: 8) {
                Text(result.wasValid ? "Great Reading!" : "Session Issues")
                    .font(.title.weight(.bold))
                
                if result.cheatingDetected {
                    Text("Some pages weren't counted due to fast reading detection.")
                        .font(.body)
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Stats
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("\(result.pagesRead)")
                        .font(.title.weight(.bold))
                    Text("Pages")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text(result.formattedDuration)
                        .font(.title.weight(.bold))
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("+\(result.pagesRead * 5)")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.accent)
                    Text("XP")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.accent, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                animate = true
            }
        }
    }
}
