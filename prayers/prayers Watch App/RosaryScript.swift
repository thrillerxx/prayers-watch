import Foundation

enum RosaryMystery: String, CaseIterable, Identifiable {
    case joyful
    case sorrowful
    case glorious
    case luminous

    var id: String { rawValue }

    var title: String {
        switch self {
        case .joyful: return "Joyful"
        case .sorrowful: return "Sorrowful"
        case .glorious: return "Glorious"
        case .luminous: return "Luminous"
        }
    }

    /// Rosary mystery content is loaded from `rosary_prayers_en.json` via ids:
    /// - mystery_<set>_<1-5>_title
    /// - mystery_<set>_<1-5>_meditation
    ///
    /// This enum only provides the set key used to build those ids.
    var contentKey: String { rawValue }

    static func defaultForToday(_ date: Date = Date(), calendar: Calendar = .current) -> RosaryMystery {
        // Traditional default by weekday (can be overridden later with a user setting).
        // Sunday: Glorious
        // Monday: Joyful
        // Tuesday: Sorrowful
        // Wednesday: Glorious
        // Thursday: Luminous
        // Friday: Sorrowful
        // Saturday: Joyful
        let wd = calendar.component(.weekday, from: date)
        switch wd {
        case 1: return .glorious
        case 2: return .joyful
        case 3: return .sorrowful
        case 4: return .glorious
        case 5: return .luminous
        case 6: return .sorrowful
        case 7: return .joyful
        default: return .joyful
        }
    }

}

enum RosaryStepContent: Codable {
    case prayerId(String)
    case text(String)

    private enum CodingKeys: String, CodingKey { case kind, value }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(String.self, forKey: .kind)
        let value = try c.decode(String.self, forKey: .value)
        switch kind {
        case "prayerId": self = .prayerId(value)
        case "text": self = .text(value)
        default:
            self = .text(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .prayerId(let id):
            try c.encode("prayerId", forKey: .kind)
            try c.encode(id, forKey: .value)
        case .text(let t):
            try c.encode("text", forKey: .kind)
            try c.encode(t, forKey: .value)
        }
    }
}

struct RosaryStep: Identifiable, Codable {
    let id: String
    let title: String
    let content: RosaryStepContent
}

enum RosaryScripts {
    static func full(
        mystery: RosaryMystery,
        includeFatima: Bool,
        includeStJoseph: Bool
    ) -> [RosaryStep] {
        var steps: [RosaryStep] = []

        func prayer(_ id: String, title: String) {
            steps.append(RosaryStep(id: UUID().uuidString, title: title, content: .prayerId(id)))
        }

        func text(_ value: String, title: String) {
            steps.append(RosaryStep(id: UUID().uuidString, title: title, content: .text(value)))
        }

        // Opening
        prayer("sign_of_cross", title: "Sign of the Cross")
        prayer("apostles_creed", title: "Apostles' Creed")
        prayer("our_father", title: "Our Father")
        prayer("hail_mary", title: "Hail Mary")
        prayer("hail_mary", title: "Hail Mary")
        prayer("hail_mary", title: "Hail Mary")
        prayer("glory_be", title: "Glory Be")

        // Decades (5 mysteries)
        for i in 1...5 {
            let medId = "mystery_\(mystery.contentKey)_\(i)_meditation"
            // The actual title + meditation are rendered from prayer ids at runtime.
            // (RosaryView maps *_meditation -> corresponding *_title.)
            prayer(medId, title: "Mystery \(i) — \(mystery.title)")

            prayer("our_father", title: "Our Father")
            for _ in 0..<10 {
                prayer("hail_mary", title: "Hail Mary")
            }
            prayer("glory_be", title: "Glory Be")
            if includeFatima {
                prayer("fatima", title: "Fatima Prayer")
            }
        }

        // Closing
        prayer("hail_holy_queen", title: "Hail Holy Queen")

        // Dialogue (USCCB)
        text("V. Pray for us, O holy Mother of God.", title: "Prayer")
        text("R. That we may be made worthy of the promises of Christ.", title: "Prayer")

        prayer("rosary_prayer", title: "Let us pray")

        if includeStJoseph {
            prayer("st_joseph_after_rosary", title: "St. Joseph")
        }

        prayer("sign_of_cross", title: "Sign of the Cross")

        return steps
    }
}
