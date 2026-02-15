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
        let logURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("prayerstore_probe.log")

        func append(_ line: String) {
            let s = line + "\n"
            if let data = s.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: logURL.path) {
                    if let fh = try? FileHandle(forWritingTo: logURL) {
                        try? fh.seekToEnd()
                        try? fh.write(contentsOf: data)
                        try? fh.close()
                    }
                } else {
                    try? data.write(to: logURL, options: .atomic)
                }
            }
        }

        append("[PrayerStore] Probe: starting")
        do {
            let prayers = try PrayerStore.load()
            append("[PrayerStore] Decode: OK")
            append("[PrayerStore] Entries: \(prayers.count)")
        } catch {
            append("[PrayerStore] Decode: FAIL")
            append("[PrayerStore] Error: \(error)")
        }
        append("[PrayerStore] Probe: done")
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
