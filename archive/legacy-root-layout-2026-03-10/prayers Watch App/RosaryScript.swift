import Foundation

enum MysterySet: String, CaseIterable, Identifiable {
    case joyful = "Joyful"
    case sorrowful = "Sorrowful"
    case glorious = "Glorious"
    case luminous = "Luminous"

    var id: String { rawValue }
}

struct RosaryStep: Identifiable {
    enum Kind {
        case prayer(id: String)
        case announcement(text: String)
    }

    let id: String
    let title: String
    let kind: Kind
}

enum RosaryScripts {
    static func full(set: MysterySet) -> [RosaryStep] {
        var steps: [RosaryStep] = []

        // Opening
        steps.append(.init(id: "soc", title: "Sign of the Cross", kind: .prayer(id: "sign_of_cross")))
        steps.append(.init(id: "creed", title: "Apostles’ Creed", kind: .prayer(id: "apostles_creed")))
        steps.append(.init(id: "of_open", title: "Our Father", kind: .prayer(id: "our_father")))
        for i in 1...3 {
            steps.append(.init(id: "hm_open_\(i)", title: "Hail Mary (\(i)/3)", kind: .prayer(id: "hail_mary")))
        }
        steps.append(.init(id: "gb_open", title: "Glory Be", kind: .prayer(id: "glory_be")))
        steps.append(.init(id: "fatima_open", title: "Fatima Prayer", kind: .prayer(id: "fatima_prayer")))

        // Decades
        let mysteries = mysteriesFor(set)
        for (d, mystery) in mysteries.enumerated() {
            let decade = d + 1
            steps.append(.init(id: "mystery_\(decade)", title: "Mystery \(decade)", kind: .announcement(text: mystery)))
            steps.append(.init(id: "of_\(decade)", title: "Our Father", kind: .prayer(id: "our_father")))
            for i in 1...10 {
                steps.append(.init(id: "hm_\(decade)_\(i)", title: "Hail Mary (\(i)/10)", kind: .prayer(id: "hail_mary")))
            }
            steps.append(.init(id: "gb_\(decade)", title: "Glory Be", kind: .prayer(id: "glory_be")))
            steps.append(.init(id: "fatima_\(decade)", title: "Fatima Prayer", kind: .prayer(id: "fatima_prayer")))
        }

        // Closing
        steps.append(.init(id: "hhq", title: "Hail Holy Queen", kind: .prayer(id: "hail_holy_queen")))
        steps.append(.init(id: "end", title: "Sign of the Cross", kind: .prayer(id: "sign_of_cross")))

        return steps
    }

    private static func mysteriesFor(_ set: MysterySet) -> [String] {
        switch set {
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
