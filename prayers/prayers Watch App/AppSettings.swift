import Foundation
import SwiftUI

/// Shared user-tunable settings for the watch app.
/// Uses AppStorage so values persist across launches.
enum AppSettings {
    // Speech
    static let voiceLanguageKey = "settings.voiceLanguage"      // e.g. en-US (system TTS fallback)
    static let rosaryVoiceKey = "settings.rosary.voice"         // RosaryVoice rawValue (machine | ElevenLabs bank)

    // New pacing controls
    static let speechSpeedKey = "settings.rosary.speechSpeed"   // veryslow|slow|normal|fast
    static let pauseBetweenPartsKey = "settings.rosary.pauseSeconds" // Int (1-10)

    // Rosary
    static let autoAdvanceKey = "settings.rosary.autoAdvance"   // Bool
    static let hapticsKey = "settings.rosary.haptics"           // Bool
    static let includeFatimaKey = "settings.rosary.includeFatima" // Bool
    static let includeStJosephKey = "settings.rosary.includeStJoseph" // Bool
    /// Rosary now-playing bead indicator layout (more styles later).
    static let beadIndicatorStyleKey = "settings.rosary.beadIndicatorStyle"

    // Appearance (named presets)
    static let colorThemeKey = "settings.appearance.colorTheme" // String rawValue AppColorTheme
    /// iOS alternate app icon asset name, or empty for the primary icon. Synced to the paired iPhone via WatchConnectivity.
    static let appAlternateIconKey = "settings.appearance.alternateAppIcon"

    // Defaults
    static let defaultVoiceLanguage = "en-US"
    static let defaultRosaryVoice = "will"
    static let defaultSpeechSpeed = "slow" // veryslow|slow|normal|fast
    static let defaultPauseBetweenPartsSeconds = 2
    static let defaultAutoAdvance = true
    static let defaultHaptics = true
    static let defaultIncludeFatima = true
    static let defaultIncludeStJoseph = false

    static let defaultColorTheme = AppColorTheme.divinity.rawValue

    static func normalizedSpeechSpeed(_ raw: String?) -> String {
        switch raw ?? defaultSpeechSpeed {
        case "veryslow": return "veryslow"
        case "normal": return "normal"
        case "fast": return "fast"
        default: return "slow"
        }
    }

    /// AVSpeechUtterance.rate for system TTS fallback.
    static func avSpeechRate(forSpeed raw: String?) -> Float {
        switch normalizedSpeechSpeed(raw) {
        case "veryslow": return 0.32
        case "normal": return 0.46
        case "fast": return 0.54
        default: return 0.40
        }
    }

    /// AVAudioPlayer.rate for bundled ElevenLabs clips (0.5…2.0).
    static func clipPlaybackRate(forSpeed raw: String?) -> Float {
        switch normalizedSpeechSpeed(raw) {
        case "veryslow": return 0.65
        case "normal": return 1.00
        case "fast": return 1.20
        default: return 0.82
        }
    }
}
