import SwiftUI

struct RosaryView: View {

    private struct RosaryTransportRow: View {
        @ObservedObject var speech: SpeechManager
        let playPauseTapped: () -> Void
        let stopTapped: () -> Void

        var body: some View {
            HStack(spacing: 10) {
                Button {
                    playPauseTapped()
                } label: {
                    Image(systemName: speech.isSpeaking ? "pause.fill" : "play.fill")
                        .font(.body.weight(.semibold))
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("TransportPlayPause")

                Button {
                    stopTapped()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.body.weight(.semibold))
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("TransportStop")
            }
        }
    }

    @State private var prayersById: [String: Prayer] = [:]
    @State private var errorText: String?

    // v1: English-only until Spanish copy is verified.
    private let lang: String = "en"

    @State private var selectedMystery: RosaryMystery? = nil
    @State private var steps: [RosaryStep] = []
    @State private var index: Int = 0

    // Playback state machine guards
    @State private var playbackGeneration: Int = 0
    @State private var isTransitioningStep: Bool = false

    // Cancellable auto-advance work
    @State private var autoAdvanceTask: Task<Void, Never>? = nil

    @AppStorage(AppSettings.autoAdvanceKey) private var autoAdvance: Bool = AppSettings.defaultAutoAdvance
    @AppStorage(AppSettings.hapticsKey) private var hapticsOn: Bool = AppSettings.defaultHaptics
    @AppStorage(AppSettings.voiceLanguageKey) private var voiceLanguage: String = AppSettings.defaultVoiceLanguage
    @AppStorage(AppSettings.speechSpeedKey) private var speechSpeed: String = AppSettings.defaultSpeechSpeed
    @AppStorage(AppSettings.pauseBetweenPartsKey) private var pauseBetweenPartsSeconds: Int = AppSettings.defaultPauseBetweenPartsSeconds

    @StateObject private var speech = SpeechManager.shared

    var body: some View {
        VStack(spacing: 8) {
            if let errorText {
                Text(errorText)
                    .font(.footnote)
                    .foregroundStyle(.red)
            } else if selectedMystery == nil {
                List {
                    ForEach(RosaryMystery.allCases) { mystery in
                        Button {
                            start(mystery)
                        } label: {
                            Text(mystery.title)
                        }
                    }
                }
            } else {
                Text(displayTitle)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .lineSpacing(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                if let label = hailMaryCounterLabel {
                    Text(label)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }

                ScrollView {
                    Text(currentText ?? "")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                Toggle("Auto", isOn: $autoAdvance)
                    .toggleStyle(.switch)

                RosaryTransportRow(
                    speech: speech,
                    playPauseTapped: { Task { @MainActor in playPauseTapped() } },
                    stopTapped: { Task { @MainActor in stopPlayback() } }
                )
                .padding(.top, 4)

                HStack(spacing: 10) {
                    Button("Back") { back() }
                        .accessibilityIdentifier("RosaryBack")
                        .frame(maxWidth: .infinity)
                        .disabled(index == 0)

                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .navigationTitle("Rosary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPrayers()
            autostartIfRequested()
        }
    }

    private func autostartIfRequested() {
        // Allows automation without UI taps (e.g. simulator launches).
        // Usage: xcrun simctl launch ... --args --autoplay
        guard ProcessInfo.processInfo.arguments.contains("--autoplay") else { return }

        let mystery = RosaryMystery.defaultForToday()
        start(mystery)

        // Speak after state updates land
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            transition(to: index, reason: .manualStart)
        }
    }


    private var currentStep: RosaryStep? {
        guard steps.indices.contains(index) else { return nil }
        return steps[index]
    }

    private var currentText: String? {
        guard let step = currentStep else { return nil }
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
        // If this is a mystery meditation step, show the mystery title loaded from JSON.
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
        // Show counter only during the 10 Hail Mary steps of a decade.
        guard step.title == "Hail Mary" else { return nil }

        // Find the start of this decade's Hail Mary run by scanning backwards
        // until we hit the preceding Our Father.
        var startIndex = index
        while startIndex > 0 {
            let prev = steps[startIndex - 1]
            if prev.title == "Our Father" { break }
            // Stop if we hit another non-Hail Mary prayer (safety)
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

        // Verification log: we expect 10 ids per set (5 titles + 5 meditations).
        let ids = (1...5).flatMap { i in
            [
                "mystery_\(mystery.contentKey)_\(i)_title",
                "mystery_\(mystery.contentKey)_\(i)_meditation"
            ]
        }
        print("[Mysteries] set=\(mystery.rawValue) count=\(ids.count) first=\(ids.first ?? "") last=\(ids.last ?? "")")
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
    private func transition(to newIndex: Int, reason: TransitionReason, spokenIndex: Int? = nil, callbackGeneration: Int? = nil) {
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

        // Start speech once (auto or manual start).
        guard autoAdvance || reason == .manualStart else { return }
        speakStep(at: index)
    }

    @MainActor
    private func speakStep(at idx: Int) {
        guard steps.indices.contains(idx) else { return }
        guard let text = currentText, !text.isEmpty else { return }

        // Cancel any scheduled auto advance before starting a new utterance.
        cancelAutoTask(reason: "speakStep")

        let g = playbackGeneration
        let spokenIdx = idx

        let rate: Float
        switch speechSpeed {
        case "veryslow": rate = 0.35
        case "slow": rate = 0.42
        default: rate = 0.50 // normal
        }

        speech.speak(text: text, voiceLanguage: voiceLanguage, rate: rate) {
            DispatchQueue.main.async {
                // Completion callback hard gate.
                if g != playbackGeneration {
                    #if DEBUG
                    print("[Rosary] callback ignored (gen mismatch) cbGen=\(g) gen=\(playbackGeneration)")
                    #endif
                    return
                }
                if isTransitioningStep {
                    #if DEBUG
                    print("[Rosary] callback ignored (transitioning) gen=\(playbackGeneration)")
                    #endif
                    return
                }
                if index != spokenIdx {
                    #if DEBUG
                    print("[Rosary] callback ignored (idx changed) spoken=\(spokenIdx) idx=\(index)")
                    #endif
                    return
                }
                if !autoAdvance {
                    #if DEBUG
                    print("[Rosary] callback ignored (auto off)")
                    #endif
                    return
                }

                if index >= steps.count - 1 {
                    if hapticsOn { Haptics.success() }
                    return
                }

                // Schedule next step with cancellable task.
                let delay = Double(max(1, min(10, pauseBetweenPartsSeconds)))
                cancelAutoTask(reason: "schedule")
                autoAdvanceTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    guard !Task.isCancelled else { return }
                    // Guard again.
                    guard g == playbackGeneration else { return }
                    guard autoAdvance else { return }
                    transition(to: index + 1, reason: .autoCompletion, spokenIndex: spokenIdx, callbackGeneration: g)
                }
            }
        }
    }

    

    @MainActor
    private func stopPlayback() {
        cancelAutoTask(reason: "stop")
        autoAdvance = false
        playbackGeneration &+= 1
        speech.stop()
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

    private func back() {
        Task { @MainActor in
            cancelAutoTask(reason: "manualBack")
            transition(to: index - 1, reason: .manualBack)
        }
    }
}

#Preview {
    NavigationStack {
        RosaryView()
    }
}
