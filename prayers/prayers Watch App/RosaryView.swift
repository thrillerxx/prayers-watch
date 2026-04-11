import SwiftUI

struct RosaryView: View {

    @State private var prayersById: [String: Prayer] = [:]
    @State private var errorText: String?

    private let lang: String = "en"

    @State private var selectedMystery: RosaryMystery? = nil
    @State private var steps: [RosaryStep] = []
    @State private var index: Int = 0

    @State private var playbackGeneration: Int = 0
    @State private var isTransitioningStep: Bool = false
    @State private var autoAdvanceTask: Task<Void, Never>?

    @AppStorage(AppSettings.autoAdvanceKey) private var autoAdvance: Bool = AppSettings.defaultAutoAdvance
    @AppStorage(AppSettings.hapticsKey) private var hapticsOn: Bool = AppSettings.defaultHaptics
    @AppStorage(AppSettings.voiceLanguageKey) private var voiceLanguage: String = AppSettings.defaultVoiceLanguage
    @AppStorage(AppSettings.speechSpeedKey) private var speechSpeed: String = AppSettings.defaultSpeechSpeed
    @AppStorage(AppSettings.pauseBetweenPartsKey) private var pauseBetweenPartsSeconds: Int = AppSettings.defaultPauseBetweenPartsSeconds

    @StateObject private var speech = SpeechManager.shared

    var body: some View {
        Group {
            if let errorText {
                Text(errorText)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.horizontal, 10)
            } else if selectedMystery == nil {
                mysteryPicker
            } else {
                nowPlayingSession
            }
        }
        .navigationTitle("Rosary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPrayers()
            autostartIfRequested()
        }
    }

    private var mysteryPicker: some View {
        List {
            ForEach(RosaryMystery.allCases) { mystery in
                Button {
                    start(mystery)
                } label: {
                    Label(mystery.title, systemImage: "circle.fill")
                }
            }
        }
    }

    private var nowPlayingSession: some View {
        VStack(spacing: 0) {
            sessionHeader
                .padding(.horizontal, 12)
                .padding(.top, 6)
                .padding(.bottom, 4)

            ScrollView {
                Text(currentText ?? "")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                playerChrome
            }
        }
    }

    private var sessionHeader: some View {
        VStack(alignment: .center, spacing: 6) {
            if let mystery = selectedMystery {
                Text(mystery.title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }

            Text(displayTitle)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .lineSpacing(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .center)

            if let label = hailMaryCounterLabel {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
        }
        .onLongPressGesture(minimumDuration: 0.55) {
            Task { @MainActor in
                exitToMysteryPicker()
            }
        }
    }

    private var playerChrome: some View {
        VStack(alignment: .leading, spacing: 10) {
            progressSection

            HStack(spacing: 10) {
                Button {
                    previousStep()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.body.weight(.semibold))
                        .frame(width: 40, height: 40)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(index == 0)
                .accessibilityLabel("Previous")
                .accessibilityIdentifier("TransportPrevious")

                Button {
                    Task { @MainActor in playPauseTapped() }
                } label: {
                    Image(systemName: speech.isSpeaking ? "pause.fill" : "play.fill")
                        .font(.body.weight(.semibold))
                        .frame(width: 44, height: 44)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("TransportPlayPause")

                Button {
                    nextStep()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.body.weight(.semibold))
                        .frame(width: 40, height: 40)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(steps.isEmpty || index >= steps.count - 1)
                .accessibilityLabel("Next")
                .accessibilityIdentifier("TransportNext")
            }

            Button {
                Task { @MainActor in stopPlayback() }
            } label: {
                Label("Stop", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("TransportStop")
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let decade = decadeProgressFraction {
                Text("Decade")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                ThinProgressBar(value: decade)
            }

            Text("Rosary")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            ThinProgressBar(value: overallProgressFraction)
        }
    }

    private struct ThinProgressBar: View {
        let value: Double

        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.22))
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: max(3, geo.size.width * min(1, max(0, value))))
                }
            }
            .frame(height: 3)
        }
    }

    private var overallProgressFraction: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(index + 1) / Double(steps.count)
    }

    /// Progress through the current decade’s Hail Mary run (1...10), when applicable.
    private var decadeProgressFraction: Double? {
        guard let step = currentStep, step.title == "Hail Mary" else { return nil }
        var startIndex = index
        while startIndex > 0 {
            let prev = steps[startIndex - 1]
            if prev.title == "Our Father" { break }
            if prev.title != "Hail Mary" { break }
            startIndex -= 1
        }
        let pos = (index - startIndex) + 1
        guard pos >= 1, pos <= 10 else { return nil }
        return Double(pos) / 10.0
    }

    private func autostartIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("--autoplay") else { return }

        let mystery = RosaryMystery.defaultForToday()
        start(mystery)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            transition(to: index, reason: .manualStart)
        }
    }

    private var currentStep: RosaryStep? {
        guard steps.indices.contains(index) else { return nil }
        return steps[index]
    }

    private var currentText: String? {
        textForStep(at: index)
    }

    private func textForStep(at i: Int) -> String? {
        guard steps.indices.contains(i) else { return nil }
        let step = steps[i]
        switch step.content {
        case .text(let t):
            return t
        case .prayerId(let prayerId):
            guard let prayer = prayersById[prayerId] else {
                return "[Missing prayer: \(prayerId)]"
            }
            return prayer.translations[lang] ?? prayer.translations["en"]
        }
    }

    private var displayTitle: String {
        guard let step = currentStep else { return "Rosary" }
        if case .prayerId(let prayerId) = step.content,
           prayerId.hasPrefix("mystery_"),
           prayerId.hasSuffix("_meditation") {
            let titleId = prayerId.replacingOccurrences(of: "_meditation", with: "_title")
            if let titlePrayer = prayersById[titleId],
               let t = titlePrayer.translations[lang] ?? titlePrayer.translations["en"],
               !t.isEmpty {
                return t
            }
        }
        return step.title
    }

    private var hailMaryCounterLabel: String? {
        guard let step = currentStep else { return nil }
        guard step.title == "Hail Mary" else { return nil }

        var startIndex = index
        while startIndex > 0 {
            let prev = steps[startIndex - 1]
            if prev.title == "Our Father" { break }
            if prev.title != "Hail Mary" { break }
            startIndex -= 1
        }

        let pos = (index - startIndex) + 1
        let total = 10
        if pos < 1 || pos > total { return nil }
        return "Hail Mary \(pos)/\(total)"
    }

    private func start(_ mystery: RosaryMystery) {
        playbackGeneration &+= 1
        selectedMystery = mystery
        steps = RosaryScripts.full(mystery: mystery)
        index = 0
    }

    private func loadPrayers() {
        do {
            let prayers = try PrayerStore.load()
            prayersById = Dictionary(uniqueKeysWithValues: prayers.map { ($0.id, $0) })
        } catch {
            errorText = error.localizedDescription
        }
    }

    private enum TransitionReason {
        case manualBack
        case manualForward
        case manualStart
        case autoCompletion
    }

    @MainActor
    private func cancelAutoTask(reason: String) {
        autoAdvanceTask?.cancel()
        autoAdvanceTask = nil
        #if DEBUG
        print("[Rosary] cancelAutoTask reason=\(reason) gen=\(playbackGeneration) idx=\(index)")
        #endif
    }

    @MainActor
    private func transition(to newIndex: Int, reason: TransitionReason) {
        if isTransitioningStep {
            #if DEBUG
            print("[Rosary] transition ignored (reentry) reason=\(reason) gen=\(playbackGeneration) idx=\(index)")
            #endif
            return
        }
        isTransitioningStep = true
        defer { isTransitioningStep = false }

        cancelAutoTask(reason: "transition")

        if reason != .autoCompletion {
            playbackGeneration &+= 1
        }

        if speech.isSpeaking || speech.isPaused {
            speech.stop()
        }

        index = min(max(0, newIndex), max(steps.count - 1, 0))

        #if DEBUG
        print("[Rosary] transition reason=\(reason) gen=\(playbackGeneration) idx=\(index)")
        #endif

        switch reason {
        case .manualBack, .manualForward, .manualStart:
            speakStep(at: index)
        case .autoCompletion:
            if autoAdvance {
                speakStep(at: index)
            }
        }
    }

    @MainActor
    private func speakStep(at idx: Int) {
        guard let text = textForStep(at: idx), !text.isEmpty else { return }

        cancelAutoTask(reason: "speakStep")

        let g = playbackGeneration
        let spokenIdx = idx

        let rate: Float
        switch speechSpeed {
        case "veryslow": rate = 0.35
        case "slow": rate = 0.42
        default: rate = 0.50
        }

        speech.speak(text: text, voiceLanguage: voiceLanguage, rate: rate) {
            DispatchQueue.main.async {
                if g != playbackGeneration { return }
                if isTransitioningStep { return }
                if index != spokenIdx { return }
                if !autoAdvance { return }

                if index >= steps.count - 1 {
                    if hapticsOn { Haptics.success() }
                    return
                }

                let delay = Double(max(1, min(10, pauseBetweenPartsSeconds)))
                cancelAutoTask(reason: "schedule")
                autoAdvanceTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    guard !Task.isCancelled else { return }
                    guard g == playbackGeneration else { return }
                    guard autoAdvance else { return }
                    transition(to: index + 1, reason: .autoCompletion)
                }
            }
        }
    }

    @MainActor
    private func stopPlayback() {
        cancelAutoTask(reason: "stop")
        playbackGeneration &+= 1
        speech.stop()
    }

    @MainActor
    private func exitToMysteryPicker() {
        if hapticsOn { Haptics.click() }
        cancelAutoTask(reason: "exit")
        playbackGeneration &+= 1
        speech.stop()
        selectedMystery = nil
        steps = []
        index = 0
    }

    @MainActor
    private func playPauseTapped() {
        if speech.isSpeaking {
            speech.pause()
            return
        }
        if speech.isPaused {
            speech.resume()
            return
        }
        transition(to: index, reason: .manualStart)
    }

    private func previousStep() {
        Task { @MainActor in
            guard index > 0 else { return }
            if hapticsOn { Haptics.click() }
            transition(to: index - 1, reason: .manualBack)
        }
    }

    private func nextStep() {
        Task { @MainActor in
            guard index < steps.count - 1 else { return }
            if hapticsOn { Haptics.click() }
            transition(to: index + 1, reason: .manualForward)
        }
    }
}

#Preview {
    NavigationStack {
        RosaryView()
    }
}
