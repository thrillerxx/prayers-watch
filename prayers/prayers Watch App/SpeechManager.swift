import Foundation
import AVFoundation

/// Keeps AVSpeechSynthesizer + delegate alive across SwiftUI view re-renders.
///
/// NOTE: On Simulator, speech output can be muted/disabled depending on host audio.
/// This manager focuses on correctness + state.
final class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
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
    private var audioPlayer: AVAudioPlayer?
    private var onFinish: (() -> Void)?

    /// Last spoken payload so “from beginning” can restart without re-passing text from the view.
    private var lastSpeechText: String = ""
    private var lastSpeechVoice: String = "en-US"
    private var lastSpeechRate: Float = 0.45
    private var lastPrayerId: String?
    private var lastVoiceBank: RosaryVoice?
    private var lastSpeedPreset: String = AppSettings.defaultSpeechSpeed
    private var clipFinishWatchdog: DispatchWorkItem?

    /// The utterance currently owned by this manager. Stale `didCancel`/`didFinish` from a
    /// previous `stopSpeaking` must not clear a newer speak/pause session.
    private weak var activeUtterance: AVSpeechUtterance?

    /// watchOS / Simulator often ignore `pauseSpeaking`; we stop audio but keep payload for resume.
    private var pausedByStoppingUtterance = false

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

    /// True when the synthesizer is actually producing audio (can lag behind `state`).
    var isHardwareSpeaking: Bool {
        if let audioPlayer, audioPlayer.isPlaying { return true }
        return synthesizer.isSpeaking && !synthesizer.isPaused
    }

    var canReplayCurrentUtterance: Bool {
        !lastSpeechText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Starts speaking new text. Always stops any currently playing speech first.
    /// Bundled VoiceBank clips play when the selected voice uses them; Apple Voice uses system TTS.
    func speak(
        text: String,
        voiceLanguage: String = "en-US",
        rate: Float = 0.45,
        title: String? = nil,
        artworkSymbol: String? = nil,
        subtitle: String? = nil,
        prayerId: String? = nil,
        voiceBank: RosaryVoice? = nil,
        onFinish: (() -> Void)? = nil
    ) {
        activateSpeechAudioSession()
        stopEnginesPreservingCallback()

        pausedByStoppingUtterance = false
        self.onFinish = onFinish
        lastSpeechText = text
        lastSpeechVoice = voiceLanguage
        lastSpeechRate = rate
        lastPrayerId = prayerId
        lastVoiceBank = voiceBank
        lastSpeedPreset = AppSettings.normalizedSpeechSpeed(
            UserDefaults.standard.string(forKey: AppSettings.speechSpeedKey)
        )
        nowPlayingTitle = title
        nowPlayingArtworkSymbol = artworkSymbol
        nowPlayingSubtitle = subtitle

        if let prayerId, let voiceBank, voiceBank.usesBundledClips,
           let url = voiceBank.clipURL(prayerId: prayerId) {
            playClip(url: url, speedPreset: lastSpeedPreset, fallbackSpeechRate: rate)
            return
        }

        restartProgressTracking(estimatedDurationForText: text, rate: rate)
        state = .speaking
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: voiceLanguage)
        utterance.rate = rate
        activeUtterance = utterance
        synthesizer.speak(utterance)
    }

    func pause() {
        if state == .paused { return }

        if let audioPlayer {
            guard state == .speaking || audioPlayer.isPlaying else { return }
            cancelClipFinishWatchdog()
            audioPlayer.pause()
            freezeProgress()
            state = .paused
            return
        }

        guard state == .speaking || synthesizer.isSpeaking else { return }

        // `.word` is more reliable than `.immediate` on watchOS; Simulator often still no-ops.
        _ = synthesizer.pauseSpeaking(at: .word)
        if synthesizer.isPaused {
            pausedByStoppingUtterance = false
            freezeProgress()
            state = .paused
            return
        }

        pausedByStoppingUtterance = true
        synthesizer.stopSpeaking(at: .immediate)
        freezeProgress()
        state = .paused
    }

    func resume() {
        if let audioPlayer, state == .paused {
            audioPlayer.rate = AppSettings.clipPlaybackRate(forSpeed: lastSpeedPreset)
            audioPlayer.play()
            unfreezeProgress()
            state = .speaking
            armClipFinishWatchdog(player: audioPlayer)
            return
        }
        if synthesizer.isPaused {
            pausedByStoppingUtterance = false
            synthesizer.continueSpeaking()
            unfreezeProgress()
            state = .speaking
            return
        }
        guard state == .paused, !lastSpeechText.isEmpty else { return }
        let finish = onFinish
        speak(
            text: lastSpeechText,
            voiceLanguage: lastSpeechVoice,
            rate: lastSpeechRate,
            title: nowPlayingTitle,
            artworkSymbol: nowPlayingArtworkSymbol,
            subtitle: nowPlayingSubtitle,
            prayerId: lastPrayerId,
            voiceBank: lastVoiceBank,
            onFinish: finish
        )
    }

    func stop() {
        pausedByStoppingUtterance = false
        activeUtterance = nil
        onFinish = nil
        stopEnginesPreservingCallback()
        state = .idle
        clearNowPlayingPresentation()
    }

    /// Restart the current line of TTS from the beginning (prayer detail “rewind” control).
    func replayFromStart() {
        if let audioPlayer {
            audioPlayer.rate = AppSettings.clipPlaybackRate(forSpeed: lastSpeedPreset)
            audioPlayer.currentTime = 0
            audioPlayer.play()
            restartProgressTracking(duration: clipProgressDuration(player: audioPlayer))
            state = .speaking
            armClipFinishWatchdog(player: audioPlayer)
            return
        }
        let t = lastSpeechText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        speak(
            text: lastSpeechText,
            voiceLanguage: lastSpeechVoice,
            rate: lastSpeechRate,
            title: nowPlayingTitle,
            artworkSymbol: nowPlayingArtworkSymbol,
            subtitle: nowPlayingSubtitle,
            prayerId: lastPrayerId,
            voiceBank: lastVoiceBank,
            onFinish: nil
        )
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard utterance === activeUtterance else { return }
        activeUtterance = nil
        pausedByStoppingUtterance = false
        resetProgressTimersOnly()
        playbackProgress = 0
        state = .idle
        let cb = onFinish
        onFinish = nil
        cb?()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        guard utterance === activeUtterance else { return }
        if pausedByStoppingUtterance, state == .paused {
            activeUtterance = nil
            return
        }
        activeUtterance = nil
        resetProgressTimersOnly()
        playbackProgress = 0
        state = .idle
        onFinish = nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard player === audioPlayer else { return }
        finishClipPlayback(successfully: flag)
    }

    private func playClip(url: URL, speedPreset: String, fallbackSpeechRate: Float) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.enableRate = true
            player.prepareToPlay()
            let clipRate = AppSettings.clipPlaybackRate(forSpeed: speedPreset)
            player.rate = clipRate
            audioPlayer = player
            restartProgressTracking(duration: clipProgressDuration(player: player))
            state = .speaking
            player.play()
            player.rate = clipRate
            armClipFinishWatchdog(player: player)
        } catch {
            audioPlayer = nil
            restartProgressTracking(estimatedDurationForText: lastSpeechText, rate: fallbackSpeechRate)
            state = .speaking
            let utterance = AVSpeechUtterance(string: lastSpeechText)
            utterance.voice = AVSpeechSynthesisVoice(language: lastSpeechVoice)
            utterance.rate = fallbackSpeechRate
            activeUtterance = utterance
            synthesizer.speak(utterance)
        }
    }

    private func finishClipPlayback(successfully flag: Bool) {
        cancelClipFinishWatchdog()
        audioPlayer = nil
        resetProgressTimersOnly()
        playbackProgress = 0
        state = .idle
        let cb = onFinish
        onFinish = nil
        if flag {
            cb?()
        }
    }

    private func armClipFinishWatchdog(player: AVAudioPlayer) {
        cancelClipFinishWatchdog()
        let remaining = max(0.4, (player.duration - player.currentTime) / max(0.5, Double(player.rate)))
        let item = DispatchWorkItem { [weak self, weak player] in
            guard let self, let player, player === self.audioPlayer else { return }
            guard self.state == .speaking, !player.isPlaying else { return }
            self.finishClipPlayback(successfully: true)
        }
        clipFinishWatchdog = item
        DispatchQueue.main.asyncAfter(deadline: .now() + remaining + 0.4, execute: item)
    }

    private func cancelClipFinishWatchdog() {
        clipFinishWatchdog?.cancel()
        clipFinishWatchdog = nil
    }

    private func clipProgressDuration(player: AVAudioPlayer) -> TimeInterval {
        let rate = max(0.5, Double(player.rate))
        return max(1, player.duration / rate)
    }

    private func stopEnginesPreservingCallback() {
        cancelClipFinishWatchdog()
        audioPlayer?.delegate = nil
        audioPlayer?.stop()
        audioPlayer = nil
        synthesizer.stopSpeaking(at: .immediate)
        activeUtterance = nil
    }

    private func activateSpeechAudioSession() {
        #if os(watchOS) || os(iOS)
        let session = AVAudioSession.sharedInstance()
        // `.default` (not `.spokenAudio`) so AVAudioPlayer.enableRate actually changes clip speed.
        try? session.setCategory(.playback, mode: .default, options: [.duckOthers])
        try? session.setActive(true)
        #endif
    }

    private func restartProgressTracking(duration: TimeInterval) {
        progressTimer?.invalidate()
        progressTimer = nil
        progressSegmentStart = Date()
        progressAccumulated = 0
        playbackProgress = 0
        progressDuration = max(1, duration)

        let timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.tickProgress()
        }
        progressTimer = timer
        RunLoop.main.add(timer, forMode: .common)
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
