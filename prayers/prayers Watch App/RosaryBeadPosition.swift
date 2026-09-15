import Foundation

/// Maps the spoken step list to a physical-bead-style position for the watch indicator.
struct RosaryBeadPosition: Equatable {
    enum Phase: Equatable {
        case opening(OpeningBead)
        case decade(DecadeBead)
        case closing(ClosingBead)
    }

    enum OpeningBead: Equatable {
        case crucifix
        case largeOurFather
        case intention
        case smallFaith
        case smallHope
        case smallCharity
        case gloryBe
    }

    enum DecadeBead: Equatable {
        case meditation(decade: Int)
        case ourFather(decade: Int)
        case hailMary(decade: Int, number: Int)
        case gloryBe(decade: Int)
        case fatima(decade: Int)
    }

    enum ClosingBead: Equatable {
        case hailHolyQueen
        case concludingPrayer
        case stMichael
        case stJoseph
        case signOfCross
    }

    let phase: Phase

    var accessibilityLabel: String {
        switch phase {
        case .opening(let bead):
            switch bead {
            case .crucifix: return "Opening, Sign of the Cross or Creed"
            case .largeOurFather: return "Opening, Our Father"
            case .intention: return "Opening, intention for Faith, Hope, and Charity"
            case .smallFaith: return "Opening, Hail Mary for Faith"
            case .smallHope: return "Opening, Hail Mary for Hope"
            case .smallCharity: return "Opening, Hail Mary for Charity"
            case .gloryBe: return "Opening, Glory Be"
            }
        case .decade(let bead):
            switch bead {
            case .meditation(let d): return "Decade \(d), mystery meditation"
            case .ourFather(let d): return "Decade \(d), Our Father"
            case .hailMary(let d, let n): return "Decade \(d), Hail Mary \(n) of 10"
            case .gloryBe(let d): return "Decade \(d), Glory Be"
            case .fatima(let d): return "Decade \(d), Fatima prayer"
            }
        case .closing(let bead):
            switch bead {
            case .hailHolyQueen: return "Closing, Hail Holy Queen"
            case .concludingPrayer: return "Closing, concluding prayer"
            case .stMichael: return "Closing, Saint Michael"
            case .stJoseph: return "Closing, Saint Joseph"
            case .signOfCross: return "Closing, Sign of the Cross"
            }
        }
    }

    /// Short label for style C (fits inside the transport orb).
    var compactLabel: String {
        switch phase {
        case .opening:
            return "Op"
        case .decade(let bead):
            switch bead {
            case .meditation(let d): return "\(d)·M"
            case .ourFather(let d): return "\(d)·F"
            case .hailMary(let d, let n): return "\(d)·\(n)"
            case .gloryBe(let d): return "\(d)·G"
            case .fatima(let d): return "\(d)·Fa"
            }
        case .closing:
            return "End"
        }
    }

    static func compute(stepIndex: Int, steps: [RosaryStep], mystery: RosaryMystery) -> RosaryBeadPosition? {
        guard steps.indices.contains(stepIndex) else { return nil }
        let step = steps[stepIndex]
        guard case .prayerId(let prayerId) = step.content else { return nil }

        let firstDecadeIndex = firstDecadeStepIndex(steps: steps, mystery: mystery)
        let firstClosingIndex = firstClosingStepIndex(steps: steps)

        if let firstClosingIndex, stepIndex >= firstClosingIndex {
            return RosaryBeadPosition(phase: .closing(closingBead(prayerId: prayerId)))
        }

        if let firstDecadeIndex, stepIndex < firstDecadeIndex {
            return RosaryBeadPosition(phase: .opening(openingBead(prayerId: prayerId, step: step)))
        }

        guard let decade = MysteryArt.decadeNumber(mystery: mystery, stepIndex: stepIndex, steps: steps) else {
            return nil
        }

        if prayerId.hasSuffix("_announce") || prayerId.hasSuffix("_meditation") {
            return RosaryBeadPosition(phase: .decade(.meditation(decade: decade)))
        }
        if prayerId == "our_father" {
            return RosaryBeadPosition(phase: .decade(.ourFather(decade: decade)))
        }
        if prayerId == "hail_mary", let n = hailMaryNumber(stepIndex: stepIndex, steps: steps) {
            return RosaryBeadPosition(phase: .decade(.hailMary(decade: decade, number: n)))
        }
        if prayerId == "glory_be" {
            return RosaryBeadPosition(phase: .decade(.gloryBe(decade: decade)))
        }
        if prayerId == "fatima" {
            return RosaryBeadPosition(phase: .decade(.fatima(decade: decade)))
        }

        return RosaryBeadPosition(phase: .decade(.meditation(decade: decade)))
    }

    private static func firstDecadeStepIndex(steps: [RosaryStep], mystery: RosaryMystery) -> Int? {
        let target = "mystery_\(mystery.contentKey)_1_announce"
        return steps.firstIndex { step in
            guard case .prayerId(let id) = step.content else { return false }
            return id == target
        }
    }

    private static func firstClosingStepIndex(steps: [RosaryStep]) -> Int? {
        steps.firstIndex { step in
            guard case .prayerId(let id) = step.content else { return false }
            return id == "hail_holy_queen"
        }
    }

    private static func openingBead(prayerId: String, step: RosaryStep) -> OpeningBead {
        switch prayerId {
        case "sign_of_cross", "apostles_creed":
            return .crucifix
        case "our_father":
            return .largeOurFather
        case "opening_hail_mary_intention":
            return .intention
        case "hail_mary":
            if step.title.contains("Faith") { return .smallFaith }
            if step.title.contains("Hope") { return .smallHope }
            if step.title.contains("Charity") { return .smallCharity }
            return .smallFaith
        case "glory_be":
            return .gloryBe
        default:
            return .crucifix
        }
    }

    private static func closingBead(prayerId: String) -> ClosingBead {
        switch prayerId {
        case "hail_holy_queen": return .hailHolyQueen
        case "rosary_prayer": return .concludingPrayer
        case "st_michael": return .stMichael
        case "st_joseph_after_rosary": return .stJoseph
        case "sign_of_cross": return .signOfCross
        default: return .hailHolyQueen
        }
    }

    private static func hailMaryNumber(stepIndex: Int, steps: [RosaryStep]) -> Int? {
        var startIndex = stepIndex
        while startIndex > 0 {
            let prev = steps[startIndex - 1]
            if prev.title == "Our Father" { break }
            if prev.title != "Hail Mary" { break }
            startIndex -= 1
        }
        let pos = (stepIndex - startIndex) + 1
        guard (1...10).contains(pos) else { return nil }
        return pos
    }
}

enum RosaryBeadIndicatorStyle: String, CaseIterable, Identifiable {
    case decadeStrip
    case chainGlyph
    case medallion

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .decadeStrip: return "A — Decade strip"
        case .chainGlyph: return "B — Chain glyph"
        case .medallion: return "C — Medallion"
        }
    }

    #if DEBUG
    static let storageKey = "debug.rosary.beadIndicatorStyle"
    #endif

    static var current: RosaryBeadIndicatorStyle {
        #if DEBUG
        let raw = UserDefaults.standard.string(forKey: storageKey) ?? RosaryBeadIndicatorStyle.decadeStrip.rawValue
        return RosaryBeadIndicatorStyle(rawValue: raw) ?? .decadeStrip
        #else
        return .decadeStrip
        #endif
    }

    #if DEBUG
    static func cycleNext() {
        let all = RosaryBeadIndicatorStyle.allCases
        guard let idx = all.firstIndex(of: current) else {
            UserDefaults.standard.set(RosaryBeadIndicatorStyle.decadeStrip.rawValue, forKey: storageKey)
            return
        }
        let next = all[(idx + 1) % all.count]
        UserDefaults.standard.set(next.rawValue, forKey: storageKey)
    }
    #endif
}
