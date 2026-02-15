import Foundation
import SwiftUI

/// Shared user-tunable settings for the watch app.
/// Uses AppStorage so values persist across launches.
enum AppSettings {
    // Speech
    static let voiceLanguageKey = "settings.voiceLanguage"      // e.g. en-US

    // New pacing controls
    static let speechSpeedKey = "settings.rosary.speechSpeed"   // String preset: slow|normal|fast
    static let pauseBetweenPartsKey = "settings.rosary.pauseSeconds" // Int (1-10)

    // Rosary
    static let autoAdvanceKey = "settings.rosary.autoAdvance"   // Bool
    static let hapticsKey = "settings.rosary.haptics"           // Bool

    // Defaults
    static let defaultVoiceLanguage = "en-US"
    static let defaultSpeechSpeed = "slow" // veryslow|slow|normal
    static let defaultPauseBetweenPartsSeconds = 2
    static let defaultAutoAdvance = true
    static let defaultHaptics = true
}
