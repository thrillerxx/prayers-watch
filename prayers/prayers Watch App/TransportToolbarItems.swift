import SwiftUI

/// Global transport controls shown in the navigation bar when a speech session is active or resumable.
struct TransportToolbarItems: ToolbarContent {
    @StateObject private var speech = SpeechManager.shared

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                speech.stopAndClearSession()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.body.weight(.semibold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Stop")
            .accessibilityIdentifier("Stop")
            .disabled(!speech.hasActiveSession)
        }

        ToolbarItem(placement: .confirmationAction) {
            Button {
                speech.togglePlayPause()
            } label: {
                Image(systemName: speech.isSpeaking ? "pause.fill" : "play.fill")
                    .font(.body.weight(.semibold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(speech.isSpeaking ? "Pause" : "Play")
            .accessibilityIdentifier(speech.isSpeaking ? "Pause" : "Play")
            .disabled(!speech.canPlayPause)
        }
    }
}
