import Foundation

/// Bundled ElevenLabs Rosary voices (operator shortlist, 2026-09-16).
enum RosaryVoice: String, CaseIterable, Identifiable {
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
        case .will: return "Will"
        case .vestal: return "Vestal"
        case .sofiaSoft: return "Sofia Soft"
        case .setsuna: return "Setsuna"
        case .rowan: return "Rowan"
        case .maxwell: return "Maxwell"
        case .emma: return "Emma"
        case .deaconHugh: return "Deacon Hugh"
        }
    }

    var folderName: String { rawValue }

    static var current: RosaryVoice {
        let raw = UserDefaults.standard.string(forKey: AppSettings.rosaryVoiceKey)
            ?? AppSettings.defaultRosaryVoice
        return RosaryVoice(rawValue: raw) ?? .will
    }

    func clipURL(prayerId: String) -> URL? {
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
