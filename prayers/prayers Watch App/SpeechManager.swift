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

    private let synthesizer = AVSpeechSynthesizer()
    private var onFinish: (() -> Void)?

    // Last utterance details to allow resume/replay from global transport controls.
    private var lastUtteranceText: String?
    private var lastVoiceLanguage: String = "en-US"
    private var lastRate: Float = 0.45

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    var isSpeaking: Bool { state == .speaking }
    var isPaused: Bool { state == .paused }

    /// True when there is an active or resumable speech session (playing, paused, or replayable).
    var hasActiveSession: Bool {
        state != .idle || lastUtteranceText != nil
    }

    /// True when Play/Pause should be enabled.
    var canPlayPause: Bool {
        isSpeaking || isPaused || (state == .idle && lastUtteranceText != nil)
    }

    /// Starts speaking new text. Always stops any currently playing speech first.
    func speak(text: String, voiceLanguage: String = "en-US", rate: Float = 0.45, onFinish: (() -> Void)? = nil) {
        synthesizer.stopSpeaking(at: .immediate)

        self.onFinish = onFinish

        lastUtteranceText = text
        lastVoiceLanguage = voiceLanguage
        lastRate = rate

        state = .speaking

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: voiceLanguage)
        utterance.rate = rate
        synthesizer.speak(utterance)
    }

    func pause() {
        guard synthesizer.isSpeaking else { return }
        synthesizer.pauseSpeaking(at: .immediate)
        state = .paused
    }

    func resume() {
        guard synthesizer.isPaused else { return }
        synthesizer.continueSpeaking()
        state = .speaking
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        state = .idle
        onFinish = nil
    }

    /// Stops immediately and clears any resumable session state (no resume/replay).
    func stopAndClearSession() {
        synthesizer.stopSpeaking(at: .immediate)
        state = .idle
        onFinish = nil
        lastUtteranceText = nil
    }

    /// Global transport toggle: pause if playing, resume if paused, or replay last utterance if idle.
    func togglePlayPause() {
        if isSpeaking {
            pause()
            return
        }
        if isPaused {
            resume()
            return
        }
        guard let text = lastUtteranceText, !text.isEmpty else { return }
        speak(text: text, voiceLanguage: lastVoiceLanguage, rate: lastRate)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.state = .idle
            let cb = self.onFinish
            self.onFinish = nil
            cb?()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.state = .idle
            self.onFinish = nil
        }
    }
}
