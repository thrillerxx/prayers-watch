import Combine
import Foundation
import SwiftUI

/// Holds rosary playback state so it survives navigation (mini-player can return to session).
@MainActor
final class RosarySessionController: ObservableObject {

    @Published var prayersById: [String: Prayer] = [:]
    @Published var errorText: String?

    @Published var selectedMystery: RosaryMystery?
    @Published var steps: [RosaryStep] = []
    @Published var index: Int = 0

    var playbackGeneration: Int = 0
    var isTransitioningStep: Bool = false
    var autoAdvanceTask: Task<Void, Never>?

    private let lang = "en"
    private let speech = SpeechManager.shared

    private var defaults: UserDefaults { .standard }

    private var autoAdvance: Bool {
        (defaults.object(forKey: AppSettings.autoAdvanceKey) as? Bool) ?? AppSettings.defaultAutoAdvance
    }

    private var hapticsOn: Bool {
        (defaults.object(forKey: AppSettings.hapticsKey) as? Bool) ?? AppSettings.defaultHaptics
    }

    private var voiceLanguage: String {
        (defaults.string(forKey: AppSettings.voiceLanguageKey)) ?? AppSettings.defaultVoiceLanguage
    }

    private var speechSpeed: String {
        (defaults.string(forKey: AppSettings.speechSpeedKey)) ?? AppSettings.defaultSpeechSpeed
    }

    private var pauseBetweenPartsSeconds: Int {
        if let v = defaults.object(forKey: AppSettings.pauseBetweenPartsKey) as? Int { return v }
        return AppSettings.defaultPauseBetweenPartsSeconds
    }

    private var includeFatima: Bool {
        (defaults.object(forKey: AppSettings.includeFatimaKey) as? Bool) ?? AppSettings.defaultIncludeFatima
    }

    private var includeStJoseph: Bool {
        (defaults.object(forKey: AppSettings.includeStJosephKey) as? Bool) ?? AppSettings.defaultIncludeStJoseph
    }

    var isRosaryActive: Bool {
        selectedMystery != nil && !steps.isEmpty
    }

    var miniPlayerSubtitle: String {
        guard let m = selectedMystery else { return "" }
        return m.title
    }

    var miniPlayerTitle: String {
        guard currentStep != nil else { return "Rosary" }
        return displayTitle
    }

    func loadPrayers() {
        do {
            let prayers = try PrayerStore.load()
            prayersById = Dictionary(uniqueKeysWithValues: prayers.map { ($0.id, $0) })
        } catch {
            errorText = error.localizedDescription
        }
    }

    func autostartIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("--autoplay") else { return }

        let mystery = RosaryMystery.defaultForToday()
        start(mystery)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.transition(to: self?.index ?? 0, reason: .manualStart)
        }
    }

    var currentStep: RosaryStep? {
        guard steps.indices.contains(index) else { return nil }
        return steps[index]
    }

    func textForStep(at i: Int) -> String? {
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

    var displayTitle: String {
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

    var hailMaryCounterLabel: String? {
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

    func start(_ mystery: RosaryMystery) {
        playbackGeneration &+= 1
        selectedMystery = mystery
        steps = RosaryScripts.full(
            mystery: mystery,
            includeFatima: includeFatima,
            includeStJoseph: includeStJoseph
        )
        index = 0
    }

    enum TransitionReason {
        case manualBack
        case manualForward
        case manualStart
        case autoCompletion
    }

    func cancelAutoTask(reason: String) {
        autoAdvanceTask?.cancel()
        autoAdvanceTask = nil
        #if DEBUG
        print("[Rosary] cancelAutoTask reason=\(reason) gen=\(playbackGeneration) idx=\(index)")
        #endif
    }

    func transition(to newIndex: Int, reason: TransitionReason) {
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

    func speakStep(at idx: Int) {
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

        speech.speak(text: text, voiceLanguage: voiceLanguage, rate: rate) { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                if g != self.playbackGeneration { return }
                if self.isTransitioningStep { return }
                if self.index != spokenIdx { return }
                if !self.autoAdvance { return }

                if self.index >= self.steps.count - 1 {
                    if self.hapticsOn { Haptics.success() }
                    return
                }

                let delay = Double(max(1, min(10, self.pauseBetweenPartsSeconds)))
                self.cancelAutoTask(reason: "schedule")
                self.autoAdvanceTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    guard !Task.isCancelled else { return }
                    guard g == self.playbackGeneration else { return }
                    guard self.autoAdvance else { return }
                    self.transition(to: self.index + 1, reason: .autoCompletion)
                }
            }
        }
    }

    func stopPlayback() {
        cancelAutoTask(reason: "stop")
        playbackGeneration &+= 1
        speech.stop()
    }

    func exitToMysteryPicker() {
        if hapticsOn { Haptics.click() }
        cancelAutoTask(reason: "exit")
        playbackGeneration &+= 1
        speech.stop()
        selectedMystery = nil
        steps = []
        index = 0
    }

    func playPauseTapped() {
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

    func previousStep() {
        if index == 0 {
            if hapticsOn { Haptics.click() }
            transition(to: 0, reason: .manualStart)
            return
        }
        if hapticsOn { Haptics.click() }
        transition(to: index - 1, reason: .manualBack)
    }

    func nextStep() {
        guard index < steps.count - 1 else { return }
        if hapticsOn { Haptics.click() }
        transition(to: index + 1, reason: .manualForward)
    }

    var overallProgressFraction: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(index + 1) / Double(steps.count)
    }

    func decadeProgressFraction() -> Double? {
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
}
