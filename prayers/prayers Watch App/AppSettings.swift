import Foundation
import SwiftUI

/// Shared user-tunable settings for the watch app.
/// Uses AppStorage so values persist across launches.
enum AppSettings {
    // Speech
    static let voiceLanguageKey = "settings.voiceLanguage"      // e.g. en-US
    static let speechRateKey = "settings.speechRate"            // Float (0.0 - 1.0-ish)

    // Rosary
    static let autoAdvanceKey = "settings.rosary.autoAdvance"   // Bool
    static let hapticsKey = "settings.rosary.haptics"           // Bool

    // Defaults
    static let defaultVoiceLanguage = "en-US"
    static let defaultSpeechRate: Float = 0.45
    static let defaultAutoAdvance = true
    static let defaultHaptics = true
}
