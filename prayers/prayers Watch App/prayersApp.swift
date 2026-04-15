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
            AppShell(theme: theme)
                .environmentObject(rosarySession)
        }
    }
}

/// Hosts the main UI. Rosary “now playing” installs `WatchMediaTimeSuppressor` inside `RosaryView` so it sits in the NavigationStack
/// content subtree (window-level overlay did not hide the status clock on 46mm for some layouts).
private struct AppShell: View {
    let theme: AppColorTheme
    @EnvironmentObject private var rosarySession: RosarySessionController

    var body: some View {
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
        .environment(\.appColorTheme, theme)
        .preferredColorScheme(.dark)
        .onAppear {
            WatchCompanionIconSync.shared.activate()
        }
    }
}
