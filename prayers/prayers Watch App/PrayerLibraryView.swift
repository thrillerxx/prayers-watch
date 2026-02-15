import SwiftUI
import AVFoundation

struct PrayerLibraryView: View {
    @State private var prayers: [Prayer] = []
    @State private var errorText: String?
    private let lang: String = "en"

    var body: some View {
        VStack(spacing: 8) {
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
                    // Hide mystery set metadata rows (keep per-mystery title/meditation entries).
                    // Examples to hide:
                    // - mysteryset_<set>_title
                    // - mysteryset_<set>_description
                    // - mysteryset_luminous_alt_title
                    !prayer.id.hasPrefix("mysteryset_")
                }
            } catch {
                errorText = error.localizedDescription
            }
        }
    }
}

struct PrayerDetailView: View {
    let prayer: Prayer
    private let lang: String = "en"

    @StateObject private var speech = SpeechManager.shared

    private var text: String {
        prayer.translations[lang] ?? prayer.translations["en"] ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(prayer.title)
                    .font(.headline)

                if text.isEmpty {
                    Text("No text for this prayer in the selected language.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text(text)
                        .font(.body)
                }

                Button {
                    if speech.isSpeaking {
                        speech.pause()
                    } else if speech.isPaused {
                        speech.resume()
                    } else {
                        speak()
                    }
                } label: {
                    Text(speech.isSpeaking ? "Pause" : (speech.isPaused ? "Resume" : "Speak"))
                }
                .disabled(text.isEmpty)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Prayer")
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
