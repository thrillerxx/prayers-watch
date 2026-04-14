//
//  prayersApp.swift
//  prayers Watch App
//
//  Created by Car Gonzalez on 2/5/26.
//

import AVFoundation
import AVKit
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

/// Hosts the main UI and, during an active Rosary mystery session, a window-level media surface so watchOS hides the status-bar clock.
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
        .overlay {
            if rosarySession.selectedMystery != nil {
                WatchMediaTimeSuppressor()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
    }
}

/// Plays an inaudible loop so watchOS treats the app as media and suppresses the corner digital time (see `silent_time_suppressor.mp4`).
/// `AVPlayerLooper` is unavailable on watchOS; restart from zero at item end instead.
private struct WatchMediaTimeSuppressor: View {
    @State private var player: AVPlayer?
    @State private var endObserver: NSObjectProtocol?

    var body: some View {
        VideoPlayer(player: player) {
            EmptyView()
        }
        .focusable(false)
        .disabled(true)
        /// Fully transparent layers are sometimes ignored for “now playing”; keep a hair of alpha so watchOS suppresses the status-bar clock.
        .opacity(0.01)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .ignoresSafeArea()
        .onAppear(perform: startPlayback)
        .onDisappear(perform: stopPlayback)
    }

    private func startPlayback() {
        guard player == nil,
              let url = Bundle.main.url(forResource: "silent_time_suppressor", withExtension: "mp4")
        else { return }

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        let item = AVPlayerItem(url: url)
        let p = AVPlayer(playerItem: item)
        p.isMuted = true
        p.actionAtItemEnd = .none

        let loopPlayer = p
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            loopPlayer.seek(to: .zero) { _ in loopPlayer.play() }
        }

        player = p
        p.play()
    }

    private func stopPlayback() {
        if let token = endObserver {
            NotificationCenter.default.removeObserver(token)
            endObserver = nil
        }
        player?.pause()
        player = nil
    }
}
