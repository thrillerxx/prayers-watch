//
//  prayersApp.swift
//  prayers Watch App
//
//  Created by Car Gonzalez on 2/5/26.
//

import SwiftUI

@main
struct prayers_Watch_AppApp: App {
    init() {
        #if DEBUG
        do {
            let prayers = try PrayerStore.load()
            print("[PrayerStore] Decode: OK")
            print("[PrayerStore] Entries: \(prayers.count)")
        } catch {
            print("[PrayerStore] Decode: FAIL")
            print("[PrayerStore] Error: \(error)")
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.arguments.contains("--autoplay") {
                RosaryView()
            } else {
                ContentView()
            }
        }
    }
}
