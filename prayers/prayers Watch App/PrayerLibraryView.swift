import SwiftUI
import AVFoundation

final class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    var onFinish: (() -> Void)?

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinish?()
    }
}

struct PrayerLibraryView: View {
    @State private var prayers: [Prayer] = []
    @State private var errorText: String?
    @State private var lang: String = "en"   // default English

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Button("EN") { lang = "en" }
                    .buttonStyle(.bordered)
                    .tint(lang == "en" ? .green : .gray)

                Button("ES") { lang = "es" }
                    .buttonStyle(.bordered)
                    .tint(lang == "es" ? .green : .gray)
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
                        PrayerDetailView(prayer: prayer, lang: lang)
                    } label: {
                        Text(prayer.title)
                    }
                }
            }
        }
        .navigationTitle("Prayers")
        .onAppear {
            do {
                prayers = try PrayerStore.load()
            } catch {
                errorText = error.localizedDescription
            }
        }
    }
}

struct PrayerDetailView: View {
    let prayer: Prayer
    let lang: String

    @State private var isSpeaking = false
    private let synthesizer = AVSpeechSynthesizer()
    private let speechDelegate = SpeechDelegate()

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
                    speak()
                } label: {
                    Text(isSpeaking ? "Speaking…" : "Speak")
                }
                .disabled(isSpeaking || text.isEmpty)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Prayer")
    }

    private func speak() {
        guard !text.isEmpty else { return }

        isSpeaking = true

        speechDelegate.onFinish = {
            DispatchQueue.main.async {
                isSpeaking = false
            }
        }
        synthesizer.delegate = speechDelegate

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: lang == "es" ? "es-MX" : "en-US")
        utterance.rate = 0.45

        synthesizer.speak(utterance)
    }
}

#Preview {
    NavigationStack {
        PrayerLibraryView()
    }
}
