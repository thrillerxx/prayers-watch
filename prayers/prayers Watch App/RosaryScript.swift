import Foundation

enum RosaryMystery: String, CaseIterable, Identifiable {
    /// Listing order follows the life of Christ: Joyful, Luminous, Sorrowful, Glorious.
    /// `CaseIterable` drives the mystery picker — do not reorder without updating tests.
    case joyful
    case luminous
    case sorrowful
    case glorious

    var id: String { rawValue }

    var title: String {
        switch self {
        case .joyful: return "Joyful"
        case .luminous: return "Luminous"
        case .sorrowful: return "Sorrowful"
        case .glorious: return "Glorious"
        }
    }

    /// Rosary mystery content is loaded from `rosary_prayers_en.json` via ids:
    /// - mystery_<set>_<1-5>_title
    /// - mystery_<set>_<1-5>_announce
    /// - mystery_<set>_<1-5>_meditation
    var contentKey: String { rawValue }

    /// Traditional assignment: one set per session. Sunday is Glorious, except Advent and Lent (Sorrowful).
    static func defaultForToday(_ date: Date = Date(), calendar: Calendar = .current) -> RosaryMystery {
        let wd = calendar.component(.weekday, from: date)
        switch wd {
        case 1:
            return RosaryLiturgicalCalendar.isAdventOrLent(date, calendar: calendar) ? .sorrowful : .glorious
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

/// Western Advent / Lent windows used only for Sunday mystery assignment.
enum RosaryLiturgicalCalendar {
    static func isAdventOrLent(_ date: Date, calendar: Calendar = .current) -> Bool {
        isAdvent(date, calendar: calendar) || isLent(date, calendar: calendar)
    }

    static func isAdvent(_ date: Date, calendar: Calendar = .current) -> Bool {
        let year = calendar.component(.year, from: date)
        guard let start = firstSundayOfAdvent(year: year, calendar: calendar),
              let christmas = date(year: year, month: 12, day: 25, calendar: calendar) else {
            return false
        }
        return date >= start && date < christmas
    }

    /// Ash Wednesday through Holy Saturday (Easter Sunday is not Lent).
    static func isLent(_ date: Date, calendar: Calendar = .current) -> Bool {
        let year = calendar.component(.year, from: date)
        guard let easter = easterDate(year: year, calendar: calendar),
              let ashWednesday = calendar.date(byAdding: .day, value: -46, to: easter),
              let holySaturday = calendar.date(byAdding: .day, value: -1, to: easter) else {
            return false
        }
        return date >= startOfDay(ashWednesday, calendar: calendar)
            && date <= endOfDay(holySaturday, calendar: calendar)
    }

    static func firstSundayOfAdvent(year: Int, calendar: Calendar = .current) -> Date? {
        guard let christmas = date(year: year, month: 12, day: 25, calendar: calendar) else { return nil }
        let christmasWeekday = calendar.component(.weekday, from: christmas)
        let daysBackToSunday = (christmasWeekday - 1 + 7) % 7
        let sundayOnOrBeforeChristmas = calendar.date(byAdding: .day, value: -daysBackToSunday, to: christmas)
        // If Christmas is Sunday, Advent IV is the previous Sunday.
        let adventIV: Date?
        if daysBackToSunday == 0 {
            adventIV = calendar.date(byAdding: .day, value: -7, to: christmas)
        } else {
            adventIV = sundayOnOrBeforeChristmas
        }
        guard let adventIV else { return nil }
        return calendar.date(byAdding: .day, value: -21, to: adventIV)
    }

    /// Anonymous Gregorian computus (Western Easter).
    static func easterDate(year: Int, calendar: Calendar = .current) -> Date? {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1
        return date(year: year, month: month, day: day, calendar: calendar)
    }

    private static func date(year: Int, month: Int, day: Int, calendar: Calendar) -> Date? {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return calendar.date(from: comps).map { startOfDay($0, calendar: calendar) }
    }

    private static func startOfDay(_ date: Date, calendar: Calendar) -> Date {
        calendar.startOfDay(for: date)
    }

    private static func endOfDay(_ date: Date, calendar: Calendar) -> Date {
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? date
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
    static let decadeOrdinals = ["First", "Second", "Third", "Fourth", "Fifth"]

    static func full(
        mystery: RosaryMystery,
        includeFatima: Bool = true,
        includeStJoseph: Bool = false
    ) -> [RosaryStep] {
        var steps: [RosaryStep] = []

        func prayer(_ id: String, title: String) {
            steps.append(RosaryStep(id: UUID().uuidString, title: title, content: .prayerId(id)))
        }

        // Opening (crucifix → first large bead → three small beads → Glory Be)
        prayer("sign_of_cross", title: "Sign of the Cross")
        prayer("apostles_creed", title: "Apostles' Creed")
        prayer("our_father", title: "Our Father")
        prayer("opening_hail_mary_intention", title: "Intention")
        prayer("hail_mary", title: "Hail Mary — Faith")
        prayer("hail_mary", title: "Hail Mary — Hope")
        prayer("hail_mary", title: "Hail Mary — Charity")
        prayer("glory_be", title: "Glory Be")

        // Each decade: announce, reflect, Our Father, 10 Hail Marys, Glory Be, optional Fatima.
        for i in 1...5 {
            let ordinal = decadeOrdinals[i - 1]
            prayer(
                "mystery_\(mystery.contentKey)_\(i)_announce",
                title: "The \(ordinal) \(mystery.title) Mystery"
            )
            prayer(
                "mystery_\(mystery.contentKey)_\(i)_meditation",
                title: "Reflect"
            )
            prayer("our_father", title: "Our Father")
            for _ in 0..<10 {
                prayer("hail_mary", title: "Hail Mary")
            }
            prayer("glory_be", title: "Glory Be")
            if includeFatima {
                prayer("fatima", title: "Fatima Prayer")
            }
        }

        // Closing (Hail Holy Queen includes "Pray for us…"; concluding prayer is in the complete guide)
        prayer("hail_holy_queen", title: "Hail, Holy Queen")
        prayer("rosary_prayer", title: "Concluding Prayer")

        if includeStJoseph {
            prayer("st_joseph_after_rosary", title: "St. Joseph")
        }

        prayer("sign_of_cross", title: "Sign of the Cross")

        return steps
    }
}
