import AVFoundation
import AVKit
import SwiftUI

/// Invisible media surface so watchOS hides the status-bar clock during Rosary “now playing”.
/// Combines a nil `VideoPlayer` (watchOS often uses this for chrome) with a looping silent clip that has an AAC track.
struct WatchMediaTimeSuppressor: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var player: AVPlayer?
    @State private var endObserver: NSObjectProtocol?

    var body: some View {
        ZStack {
            VideoPlayer(player: nil) {
                EmptyView()
            }
            .focusable(false)
            .disabled(true)
            .opacity(0)
            .allowsHitTesting(false)
            .accessibilityHidden(true)

            VideoPlayer(player: player) {
                EmptyView()
            }
            .focusable(false)
            .disabled(true)
            .opacity(0.01)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
        .ignoresSafeArea()
        .onAppear(perform: startPlayback)
        .onDisappear(perform: stopPlayback)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { player?.play() }
        }
    }

    private func startPlayback() {
        guard player == nil,
              let url = Bundle.main.url(forResource: "silent_time_suppressor", withExtension: "mp4")
        else { return }

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        let item = AVPlayerItem(url: url)
        let p = AVPlayer(playerItem: item)
        p.isMuted = false
        p.volume = 1.0
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
