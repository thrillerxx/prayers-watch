//
//  prayers_Watch_AppTests.swift
//  prayers Watch AppTests
//
//  Created by Car Gonzalez on 2/5/26.
//

import Foundation
import Testing
@testable import prayers_Watch_App

struct prayers_Watch_AppTests {

    private func utcCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func utcDate(year: Int, month: Int, day: Int) -> Date {
        let calendar = utcCalendar()
        let comps = DateComponents(calendar: calendar, year: year, month: month, day: day)
        return calendar.date(from: comps)!
    }

    private func prayerId(_ step: RosaryStep) -> String? {
        if case .prayerId(let id) = step.content { return id }
        return nil
    }

    @Test func mysteryPickerListsSetsInLifeOfChristOrder() async throws {
        #expect(RosaryMystery.allCases.map(\.rawValue) == [
            "joyful",
            "luminous",
            "sorrowful",
            "glorious",
        ])
    }

    @Test func weekdayMysteryAssignmentFollowsGuide() async throws {
        let calendar = utcCalendar()
        // Monday 14 Sep 2026
        #expect(RosaryMystery.defaultForToday(utcDate(year: 2026, month: 9, day: 14), calendar: calendar) == .joyful)
        // Tuesday
        #expect(RosaryMystery.defaultForToday(utcDate(year: 2026, month: 9, day: 15), calendar: calendar) == .sorrowful)
        // Wednesday
        #expect(RosaryMystery.defaultForToday(utcDate(year: 2026, month: 9, day: 16), calendar: calendar) == .glorious)
        // Thursday
        #expect(RosaryMystery.defaultForToday(utcDate(year: 2026, month: 9, day: 17), calendar: calendar) == .luminous)
        // Friday
        #expect(RosaryMystery.defaultForToday(utcDate(year: 2026, month: 9, day: 18), calendar: calendar) == .sorrowful)
        // Saturday
        #expect(RosaryMystery.defaultForToday(utcDate(year: 2026, month: 9, day: 19), calendar: calendar) == .joyful)
    }

    @Test func sundayIsGloriousOutsideAdventAndLent() async throws {
        let calendar = utcCalendar()
        #expect(RosaryMystery.defaultForToday(utcDate(year: 2026, month: 9, day: 20), calendar: calendar) == .glorious)
        #expect(RosaryMystery.defaultForToday(utcDate(year: 2026, month: 4, day: 5), calendar: calendar) == .glorious)
    }

    @Test func sundayIsSorrowfulInAdventAndLent() async throws {
        let calendar = utcCalendar()
        // Lent 2026: Ash Wednesday 18 Feb; Sunday 8 Mar
        #expect(RosaryMystery.defaultForToday(utcDate(year: 2026, month: 3, day: 8), calendar: calendar) == .sorrowful)
        // Advent 2026 begins 29 Nov; Sunday 6 Dec
        #expect(RosaryMystery.defaultForToday(utcDate(year: 2026, month: 12, day: 6), calendar: calendar) == .sorrowful)
    }

    @Test func easterComputusMatchesKnownDates() async throws {
        let calendar = utcCalendar()
        let easter2026 = RosaryLiturgicalCalendar.easterDate(year: 2026, calendar: calendar)!
        #expect(calendar.component(.month, from: easter2026) == 4)
        #expect(calendar.component(.day, from: easter2026) == 5)
        let advent2026 = RosaryLiturgicalCalendar.firstSundayOfAdvent(year: 2026, calendar: calendar)!
        #expect(calendar.component(.month, from: advent2026) == 11)
        #expect(calendar.component(.day, from: advent2026) == 29)
    }

    @Test func rosaryScriptFollowsCompleteGuideOrder() async throws {
        let steps = RosaryScripts.full(mystery: .joyful, includeFatima: true, includeStJoseph: false)
        let ids = steps.compactMap(prayerId)
        #expect(Array(ids.prefix(7)) == [
            "sign_of_cross",
            "apostles_creed",
            "our_father",
            "hail_mary",
            "hail_mary",
            "hail_mary",
            "glory_be",
        ])
        #expect(steps[3].title == "Hail Mary — Faith")
        #expect(steps[4].title == "Hail Mary — Hope")
        #expect(steps[5].title == "Hail Mary — Charity")

        #expect(ids.contains("mystery_joyful_1_announce"))
        #expect(ids.contains("mystery_joyful_1_meditation"))
        let announce = ids.firstIndex(of: "mystery_joyful_1_announce")!
        let reflect = ids.firstIndex(of: "mystery_joyful_1_meditation")!
        #expect(announce < reflect)
        #expect(ids[reflect + 1] == "our_father")
        #expect(ids[(reflect + 2)..<(reflect + 12)].allSatisfy { $0 == "hail_mary" })
        #expect(ids[reflect + 12] == "glory_be")
        #expect(ids[reflect + 13] == "fatima")

        #expect(steps.contains { if case .text = $0.content { return true }; return false } == false)
        #expect(Array(ids.suffix(3)) == ["hail_holy_queen", "rosary_prayer", "sign_of_cross"])
        #expect(steps[ids.count - 2].title == "Concluding Prayer")
    }

    @Test func rosaryScriptHasFiveAnnounceAndReflectPairs() async throws {
        let steps = RosaryScripts.full(mystery: .luminous, includeFatima: false, includeStJoseph: true)
        let ids = steps.compactMap(prayerId)
        for i in 1...5 {
            #expect(ids.contains("mystery_luminous_\(i)_announce"))
            #expect(ids.contains("mystery_luminous_\(i)_meditation"))
        }
        #expect(ids.contains("st_joseph_after_rosary"))
        #expect(!ids.contains("fatima"))
    }

    @Test func mysteryArtFallsBackToFirstDecadeBeforeMeditation() async throws {
        let m = RosaryMystery.joyful
        let steps = RosaryScripts.full(mystery: m)
        #expect(MysteryArt.assetName(mystery: m, stepIndex: 0, steps: steps) == "joyful_1")
    }

    @Test func mysteryArtTracksDecadeFromAnnouncement() async throws {
        let m = RosaryMystery.sorrowful
        let steps = RosaryScripts.full(mystery: m)
        let idx = steps.firstIndex(where: { prayerId($0) == "mystery_sorrowful_3_announce" })
        #expect(idx != nil)
        guard let idx else { return }
        #expect(MysteryArt.decadeNumber(mystery: m, stepIndex: idx, steps: steps) == 3)
        #expect(MysteryArt.assetName(mystery: m, stepIndex: idx, steps: steps) == "sorrowful_3")
    }

    @Test func mysteryArtTracksDecadeFromMeditationSteps() async throws {
        let m = RosaryMystery.sorrowful
        let steps = RosaryScripts.full(mystery: m)
        let idx = steps.firstIndex(where: { prayerId($0) == "mystery_sorrowful_3_meditation" })
        #expect(idx != nil)
        guard let idx else { return }
        #expect(MysteryArt.decadeNumber(mystery: m, stepIndex: idx, steps: steps) == 3)
        #expect(MysteryArt.assetName(mystery: m, stepIndex: idx, steps: steps) == "sorrowful_3")
    }
}
