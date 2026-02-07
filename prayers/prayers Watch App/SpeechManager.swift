import Foundation
import AVFoundation

/// Keeps AVSpeechSynthesizer + delegate alive across SwiftUI view re-renders.
///
/// NOTE: On Simulator, speech output can be muted/disabled depending on host audio.
/// This manager focuses on correctness + state.
final class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking: Bool = false

    private let synthesizer = AVSpeechSynthesizer()
    private var onFinish: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(text: String, voiceLanguage: String = "en-US", rate: Float = 0.45, onFinish: (() -> Void)? = nil) {
        self.onFinish = onFinish
        isSpeaking = true

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: voiceLanguage)
        utterance.rate = rate
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        onFinish = nil
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            let cb = self.onFinish
            self.onFinish = nil
            cb?()
        }
    }
}
