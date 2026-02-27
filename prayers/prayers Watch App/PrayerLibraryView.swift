import SwiftUI
import AVFoundation

struct PrayerLibraryView: View {
    @State private var prayers: [Prayer] = []
    @State private var errorText: String?
    private let lang: String = "en"

    @StateObject private var speech = SpeechManager.shared

    var body: some View {
        VStack(spacing: 8) {
            if speech.isSpeaking || speech.isPaused {
                TransportRow(speech: speech)
                    .padding(.top, 2)
            }
            if let errorText {
                Text(errorText)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            } else if prayers.isEmpty {
                Text("No prayers found")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                List(prayers) { prayer in
                    NavigationLink {
                        PrayerDetailView(prayer: prayer)
                    } label: {
                        Text(prayer.title)
                    }
                }
            }
        }
        .navigationTitle("Prayers")
        .onAppear {
            do {
                prayers = try PrayerStore.load().filter { prayer in
                    let id = prayer.id
                    // Keep only prayable text entries.
                    // Hide any metadata/title helper rows.
                    if id.hasPrefix("mysteryset_") { return false }
                    if id.hasSuffix("_title") { return false }
                    if id.hasSuffix("_alt_title") { return false }
                    // keep everything else (including *_meditation + core prayers)
                    return true
                }
            } catch {
                errorText = error.localizedDescription
            }
        }
    }
}

private struct TransportRow: View {
    @ObservedObject var speech: SpeechManager

    var body: some View {
        HStack(spacing: 10) {
            Button {
                if speech.isSpeaking {
                    speech.pause()
                } else {
                    speech.resume()
                }
            } label: {
                Label(speech.isSpeaking ? "Pause" : "Play", systemImage: speech.isSpeaking ? "pause.fill" : "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("TransportPlayPause")

            Button {
                speech.stop()
            } label: {
                Image(systemName: "stop.fill")
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("TransportStop")
        }
    }
}

struct PrayerDetailView: View {
    let prayer: Prayer
    private let lang: String = "en"

    @StateObject private var speech = SpeechManager.shared

    @State private var didAutoplay = false

    private var text: String {
        prayer.translations[lang] ?? prayer.translations["en"] ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(prayer.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 2)

                if speech.isSpeaking || speech.isPaused {
                    TransportRow(speech: speech)
                        .padding(.top, 4)
                }

                if text.isEmpty {
                    Text("No text for this prayer in the selected language.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text(text)
                        .font(.body)
                }

            }
            .padding(.horizontal)
        }
        .navigationTitle("Prayer")
        .onAppear {
            // Always interrupt any current playback and start this prayer immediately.
            if !didAutoplay {
                didAutoplay = true
                speech.stop()
                speak()
            }
        }
    }

    private func speak() {
        guard !text.isEmpty else { return }

        speech.speak(text: text, voiceLanguage: "en-US", rate: 0.45)
    }
}

#Preview {
    NavigationStack {
        PrayerLibraryView()
    }
}
