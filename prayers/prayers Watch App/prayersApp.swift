//
//  prayersApp.swift
//  prayers Watch App
//
//  Created by Car Gonzalez on 2/5/26.
//

import SwiftUI

@main
struct prayers_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--open=settings") {
                SettingsView()
            } else if ProcessInfo.processInfo.arguments.contains("--open=library") {
                PrayerLibraryView()
            } else if ProcessInfo.processInfo.arguments.contains("--open=rosary") || ProcessInfo.processInfo.arguments.contains("--autoplay") {
                RosaryView()
            } else {
                ContentView()
            }
            #else
            if ProcessInfo.processInfo.arguments.contains("--autoplay") {
                RosaryView()
            } else {
                ContentView()
            }
            #endif
        }
    }
}
