//
//  prayersApp.swift
//  prayers Watch App
//
//  Created by Car Gonzalez on 2/5/26.
//

import SwiftUI

@main
struct prayers_Watch_AppApp: App {

    @StateObject private var rosarySession = RosarySessionController()

    @AppStorage(AppSettings.colorThemeKey) private var themeRaw: String = AppSettings.defaultColorTheme

    private var theme: AppColorTheme {
        AppColorTheme(rawValue: themeRaw) ?? .marian
    }

    var body: some Scene {
        WindowGroup {
            Group {
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("--open=settings") {
                    SettingsView()
                } else if ProcessInfo.processInfo.arguments.contains("--open=library") {
                    PrayerLibraryView()
                } else if ProcessInfo.processInfo.arguments.contains("--open=rosary") || ProcessInfo.processInfo.arguments.contains("--autoplay") {
                    RosaryView(rosaryScreenActive: .constant(true))
                } else {
                    ContentView()
                }
                #else
                if ProcessInfo.processInfo.arguments.contains("--autoplay") {
                    RosaryView(rosaryScreenActive: .constant(true))
                } else {
                    ContentView()
                }
                #endif
            }
            .environmentObject(rosarySession)
            .environment(\.appColorTheme, theme)
        }
    }
}
