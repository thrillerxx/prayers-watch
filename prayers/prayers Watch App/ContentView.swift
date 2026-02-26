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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if speech.isSpeaking {
                            speech.pause()
                        } else if speech.isPaused {
                            speech.resume()
                        }
                    } label: {
                        Image(systemName: speech.isSpeaking ? "pause.fill" : "play.fill")
                            .font(.body.weight(.semibold))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .disabled(!(speech.isSpeaking || speech.isPaused))
                    .accessibilityLabel(speech.isSpeaking ? "Pause" : "Play")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
