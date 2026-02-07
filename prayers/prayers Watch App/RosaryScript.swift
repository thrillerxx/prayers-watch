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

    var mysteries: [String] {
        switch self {
        case .joyful:
            return [
                "The Annunciation",
                "The Visitation",
                "The Nativity",
                "The Presentation",
                "The Finding in the Temple"
            ]
        case .sorrowful:
            return [
                "The Agony in the Garden",
                "The Scourging at the Pillar",
                "The Crowning with Thorns",
                "The Carrying of the Cross",
                "The Crucifixion"
            ]
        case .glorious:
            return [
                "The Resurrection",
                "The Ascension",
                "The Descent of the Holy Spirit",
                "The Assumption",
                "The Coronation of Mary"
            ]
        case .luminous:
            return [
                "The Baptism of Jesus",
                "The Wedding at Cana",
                "The Proclamation of the Kingdom",
                "The Transfiguration",
                "The Institution of the Eucharist"
            ]
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
    static func full(mystery: RosaryMystery) -> [RosaryStep] {
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

        // Decades
        for (i, m) in mystery.mysteries.enumerated() {
            text(m, title: "Mystery \(i + 1) — \(mystery.title)")
            prayer("our_father", title: "Our Father")
            for _ in 0..<10 {
                prayer("hail_mary", title: "Hail Mary")
            }
            prayer("glory_be", title: "Glory Be")
            prayer("fatima", title: "Fatima Prayer")
        }

        // Closing (minimal)
        prayer("hail_holy_queen", title: "Hail Holy Queen")
        prayer("sign_of_cross", title: "Sign of the Cross")

        return steps
    }
}
