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

    @Test func apostlesCreedMatchesSuppliedWording() async throws {
        let prayers = try PrayerStore.load()
        let creed = try #require(prayers.first { $0.id == "apostles_creed" }?.translations["en"])
        #expect(creed == "I believe in God, the Father almighty, Creator of heaven and earth, and in Jesus Christ, his only Son, our Lord, who was conceived by the Holy Spirit, born of the Virgin Mary, suffered under Pontius Pilate, was crucified, died and was buried; he descended into hell; on the third day he rose again from the dead; he ascended into heaven, and is seated at the right hand of God the Father almighty; from there he will come to judge the living and the dead. I believe in the Holy Spirit, the holy catholic Church, the communion of saints, the forgiveness of sins, the resurrection of the body, and life everlasting. Amen.")
    }

    @Test func rosaryScriptFollowsCompleteGuideOrder() async throws {
        let steps = RosaryScripts.full(mystery: .joyful, includeFatima: true, includeStJoseph: false)
        let ids = steps.compactMap(prayerId)
        #expect(Array(ids.prefix(8)) == [
            "sign_of_cross",
            "apostles_creed",
            "our_father",
            "opening_hail_mary_intention",
            "hail_mary",
            "hail_mary",
            "hail_mary",
            "glory_be",
        ])
        #expect(steps[3].title == "Intention")
        #expect(steps[4].title == "Hail Mary — Faith")
        #expect(steps[5].title == "Hail Mary — Hope")
        #expect(steps[6].title == "Hail Mary — Charity")

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
        #expect(Array(ids.suffix(4)) == ["hail_holy_queen", "rosary_prayer", "st_michael", "sign_of_cross"])
        #expect(steps[ids.count - 3].title == "Let us pray")
    }

    @Test func rosaryScriptHasFiveAnnounceAndReflectPairs() async throws {
        let steps = RosaryScripts.full(mystery: .luminous, includeFatima: false, includeStJoseph: true)
        let ids = steps.compactMap(prayerId)
        for i in 1...5 {
            #expect(ids.contains("mystery_luminous_\(i)_announce"))
            #expect(ids.contains("mystery_luminous_\(i)_meditation"))
        }
        #expect(ids.contains("st_joseph_after_rosary"))
        #expect(ids.contains("st_michael"))
        #expect(!ids.contains("fatima"))
        let michael = ids.firstIndex(of: "st_michael")!
        let joseph = ids.firstIndex(of: "st_joseph_after_rosary")!
        #expect(michael < joseph)
        #expect(ids.last == "sign_of_cross")
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

    @Test func beadPositionMapsOpeningAndDecadeSteps() async throws {
        let mystery = RosaryMystery.joyful
        let steps = RosaryScripts.full(mystery: mystery, includeFatima: true, includeStJoseph: false)

        let creedIdx = steps.firstIndex { prayerId($0) == "apostles_creed" }!
        let posCreed = RosaryBeadPosition.compute(stepIndex: creedIdx, steps: steps, mystery: mystery)!
        #expect(posCreed.phase == .opening(.crucifix))

        let hopeIdx = steps.firstIndex { $0.title.contains("Hope") }!
        let posHope = RosaryBeadPosition.compute(stepIndex: hopeIdx, steps: steps, mystery: mystery)!
        #expect(posHope.phase == .opening(.smallHope))

        let announceIdx = steps.firstIndex { prayerId($0) == "mystery_joyful_1_announce" }!
        let posAnnounce = RosaryBeadPosition.compute(stepIndex: announceIdx, steps: steps, mystery: mystery)!
        #expect(posAnnounce.phase == .decade(.meditation(decade: 1)))

        let reflectIdx = steps.firstIndex { prayerId($0) == "mystery_joyful_1_meditation" }!
        let ofIdx = reflectIdx + 1
        #expect(prayerId(steps[ofIdx]) == "our_father")
        let posOF = RosaryBeadPosition.compute(stepIndex: ofIdx, steps: steps, mystery: mystery)!
        #expect(posOF.phase == .decade(.ourFather(decade: 1)))

        let hm1Idx = ofIdx + 1
        let posHM1 = RosaryBeadPosition.compute(stepIndex: hm1Idx, steps: steps, mystery: mystery)!
        #expect(posHM1.phase == .decade(.hailMary(decade: 1, number: 1)))

        let closingIdx = steps.firstIndex { prayerId($0) == "hail_holy_queen" }!
        let posClosing = RosaryBeadPosition.compute(stepIndex: closingIdx, steps: steps, mystery: mystery)!
        #expect(posClosing.phase == .closing(.hailHolyQueen))
    }
}
