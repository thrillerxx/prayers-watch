import Foundation

/// Rosary / Library spoken voice.
/// `machine` is Apple's built-in `AVSpeechSynthesizer` (picker label: Apple Voice).
/// The rest are bundled ElevenLabs VoiceBank clips (operator shortlist, 2026-09-16).
enum RosaryVoice: String, CaseIterable, Identifiable {
    case machine
    case will
    case vestal
    case sofiaSoft = "sofia-soft"
    case setsuna
    case rowan
    case maxwell
    case emma
    case deaconHugh = "deacon-hugh"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .machine: return "Apple Voice"
        case .will: return "Will"
        case .vestal: return "Vestal"
        case .sofiaSoft: return "Sofia"
        case .setsuna: return "Setsuna"
        case .rowan: return "Rowan"
        case .maxwell: return "Maxwell"
        case .emma: return "Emma"
        case .deaconHugh: return "Deacon Hugh"
        }
    }

    var usesBundledClips: Bool { self != .machine }

    var folderName: String { rawValue }

    static var current: RosaryVoice {
        let raw = UserDefaults.standard.string(forKey: AppSettings.rosaryVoiceKey)
            ?? AppSettings.defaultRosaryVoice
        return RosaryVoice(rawValue: raw) ?? .will
    }

    func clipURL(prayerId: String) -> URL? {
        guard usesBundledClips else { return nil }
        let name = "\(folderName)__\(prayerId)"
        if let nested = Bundle.main.url(
            forResource: name,
            withExtension: "mp3",
            subdirectory: "VoiceBank"
        ) {
            return nested
        }
        // Synchronized Watch target copies resources to the app root.
        return Bundle.main.url(forResource: name, withExtension: "mp3")
    }
}
