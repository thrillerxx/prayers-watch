import SwiftUI

struct ContentView: View {
    @StateObject private var speech = SpeechManager.shared

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Rosary") {
                    RosaryView()
                }

                NavigationLink("Prayer Library") {
                    PrayerLibraryView()
                }

                NavigationLink("Settings") {
                    SettingsView()
                }
            }
            .navigationTitle("Divinity")
            .toolbar {
                if speech.isSpeaking || speech.isPaused {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            speech.stop()
                        } label: {
                            Image(systemName: "stop.fill")
                                .font(.body.weight(.semibold))
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Stop")
                        .accessibilityIdentifier("Stop")
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            if speech.isSpeaking {
                                speech.pause()
                            } else {
                                speech.resume()
                            }
                        } label: {
                            Image(systemName: speech.isSpeaking ? "pause.fill" : "play.fill")
                                .font(.body.weight(.semibold))
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(speech.isSpeaking ? "Pause" : "Play")
                        .accessibilityIdentifier(speech.isSpeaking ? "Pause" : "Play")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
