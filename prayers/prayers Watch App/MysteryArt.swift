import Foundation

enum MysteryArt {
    /// Cached pick so the home hero stays stable until the app process exits (cold start gets a new one).
    private static var cachedHomeHeroAssetName: String?

    /// Random decade image (`joyful_1` … `luminous_5`); chosen once per app launch.
    static func homeHeroAssetNameForProcess() -> String {
        if let cachedHomeHeroAssetName {
            return cachedHomeHeroAssetName
        }
        let all = RosaryMystery.allCases.flatMap { mystery in
            (1...5).map { "\(mystery.contentKey)_\($0)" }
        }
        let pick = all.randomElement() ?? "joyful_1"
        cachedHomeHeroAssetName = pick
        return pick
    }

    /// Asset catalog base name, e.g. `joyful_3`.
    static func assetName(mystery: RosaryMystery, stepIndex: Int, steps: [RosaryStep]) -> String {
        let d = decadeNumber(mystery: mystery, stepIndex: stepIndex, steps: steps) ?? 1
        return "\(mystery.contentKey)_\(d)"
    }

    /// Which of the five decades (1...5) the current step belongs to, if any.
    static func decadeNumber(mystery: RosaryMystery, stepIndex: Int, steps: [RosaryStep]) -> Int? {
        guard stepIndex >= 0, !steps.isEmpty else { return nil }
        let prefix = "mystery_\(mystery.contentKey)_"
        var last: Int?
        for i in 0...min(stepIndex, steps.count - 1) {
            guard case .prayerId(let id) = steps[i].content else { continue }
            guard id.hasPrefix(prefix), id.hasSuffix("_meditation") else { continue }
            let mid = id.dropFirst(prefix.count).dropLast("_meditation".count)
            if let n = Int(mid) { last = n }
        }
        return last
    }
}
