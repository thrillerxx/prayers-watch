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

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    var isSpeaking: Bool { state == .speaking }
    var isPaused: Bool { state == .paused }

    /// Starts speaking new text. Always stops any currently playing speech first.
    func speak(text: String, voiceLanguage: String = "en-US", rate: Float = 0.45, onFinish: (() -> Void)? = nil) {
        synthesizer.stopSpeaking(at: .immediate)

        self.onFinish = onFinish
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
