import Foundation
import AVFoundation

/// Keeps AVSpeechSynthesizer + delegate alive across SwiftUI view re-renders.
///
/// NOTE: On Simulator, speech output can be muted/disabled depending on host audio.
/// This manager focuses on correctness + state.
final class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechManager()

    enum State {
        case idle
        case speaking
        case paused
    }

    @Published private(set) var state: State = .idle

    /// Optional “now playing” identity for prayer-library style UI (nil for e.g. rosary TTS).
    @Published private(set) var nowPlayingTitle: String?
    @Published private(set) var nowPlayingArtworkSymbol: String?
    @Published private(set) var nowPlayingSubtitle: String?

    /// Rough 0…1 progress from utterance length and elapsed time (for a Spotify-style scrub track).
    @Published private(set) var playbackProgress: Double = 0

    private let synthesizer = AVSpeechSynthesizer()
    private var onFinish: (() -> Void)?

    /// Last spoken payload so “from beginning” can restart without re-passing text from the view.
    private var lastSpeechText: String = ""
    private var lastSpeechVoice: String = "en-US"
    private var lastSpeechRate: Float = 0.45

    private var progressTimer: Timer?
    private var progressSegmentStart: Date?
    private var progressAccumulated: TimeInterval = 0
    private var progressDuration: TimeInterval = 30

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    deinit {
        progressTimer?.invalidate()
    }

    var isSpeaking: Bool { state == .speaking }
    var isPaused: Bool { state == .paused }

    var canReplayCurrentUtterance: Bool {
        !lastSpeechText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Starts speaking new text. Always stops any currently playing speech first.
    func speak(
        text: String,
        voiceLanguage: String = "en-US",
        rate: Float = 0.45,
        title: String? = nil,
        artworkSymbol: String? = nil,
        subtitle: String? = nil,
        onFinish: (() -> Void)? = nil
    ) {
        synthesizer.stopSpeaking(at: .immediate)

        self.onFinish = onFinish
        lastSpeechText = text
        lastSpeechVoice = voiceLanguage
        lastSpeechRate = rate
        nowPlayingTitle = title
        nowPlayingArtworkSymbol = artworkSymbol
        nowPlayingSubtitle = subtitle

        restartProgressTracking(estimatedDurationForText: text, rate: rate)

        state = .speaking

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: voiceLanguage)
        utterance.rate = rate
        synthesizer.speak(utterance)
    }

    func pause() {
        guard synthesizer.isSpeaking else { return }
        synthesizer.pauseSpeaking(at: .immediate)
        freezeProgress()
        state = .paused
    }

    func resume() {
        guard synthesizer.isPaused else { return }
        synthesizer.continueSpeaking()
        unfreezeProgress()
        state = .speaking
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        state = .idle
        onFinish = nil
        clearNowPlayingPresentation()
    }

    /// Restart the current line of TTS from the beginning (prayer detail “rewind” control).
    func replayFromStart() {
        let t = lastSpeechText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        speak(
            text: lastSpeechText,
            voiceLanguage: lastSpeechVoice,
            rate: lastSpeechRate,
            title: nowPlayingTitle,
            artworkSymbol: nowPlayingArtworkSymbol,
            subtitle: nowPlayingSubtitle,
            onFinish: nil
        )
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        resetProgressTimersOnly()
        playbackProgress = 0
        state = .idle
        let cb = onFinish
        onFinish = nil
        cb?()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        resetProgressTimersOnly()
        playbackProgress = 0
        state = .idle
        onFinish = nil
    }

    private func restartProgressTracking(estimatedDurationForText text: String, rate: Float) {
        progressTimer?.invalidate()
        progressTimer = nil
        progressSegmentStart = Date()
        progressAccumulated = 0
        playbackProgress = 0

        let chars = max(1, text.utf16.count)
        let rateFactor = Double(max(0.28, min(0.55, rate)))
        let base = Double(chars) * 0.052 / rateFactor
        progressDuration = max(14, min(900, base))

        let timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.tickProgress()
        }
        progressTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func tickProgress() {
        guard state == .speaking, let start = progressSegmentStart else { return }
        let elapsed = progressAccumulated + Date().timeIntervalSince(start)
        playbackProgress = min(1, elapsed / progressDuration)
    }

    private func freezeProgress() {
        if let start = progressSegmentStart {
            progressAccumulated += Date().timeIntervalSince(start)
            progressSegmentStart = nil
        }
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func unfreezeProgress() {
        progressSegmentStart = Date()
        let timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.tickProgress()
        }
        progressTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func resetProgressTimersOnly() {
        progressTimer?.invalidate()
        progressTimer = nil
        progressSegmentStart = nil
        progressAccumulated = 0
    }

    private func clearNowPlayingPresentation() {
        resetProgressTimersOnly()
        playbackProgress = 0
        nowPlayingTitle = nil
        nowPlayingArtworkSymbol = nil
        nowPlayingSubtitle = nil
    }
}
