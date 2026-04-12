//
//  prayers_Watch_AppTests.swift
//  prayers Watch AppTests
//
//  Created by Car Gonzalez on 2/5/26.
//

import Testing
@testable import prayers_Watch_App

struct prayers_Watch_AppTests {

    @Test func mysteryArtFallsBackToFirstDecadeBeforeMeditation() async throws {
        let m = RosaryMystery.joyful
        let steps = RosaryScripts.full(mystery: m)
        #expect(MysteryArt.assetName(mystery: m, stepIndex: 0, steps: steps) == "joyful_1")
    }

    @Test func mysteryArtTracksDecadeFromMeditationSteps() async throws {
        let m = RosaryMystery.sorrowful
        let steps = RosaryScripts.full(mystery: m)
        let idx = steps.firstIndex(where: {
            if case .prayerId(let id) = $0.content { return id == "mystery_sorrowful_3_meditation" }
            return false
        })
        #expect(idx != nil)
        guard let idx else { return }
        #expect(MysteryArt.decadeNumber(mystery: m, stepIndex: idx, steps: steps) == 3)
        #expect(MysteryArt.assetName(mystery: m, stepIndex: idx, steps: steps) == "sorrowful_3")
    }
}
