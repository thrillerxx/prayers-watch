import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var prayers: [Prayer] = []
    @State private var errorText: String?
    @State private var lang: String = "en"
    @State private var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack(spacing: 10) {
            Text("Divinity")
                .font(.headline)

            Picker("Lang", selection: $lang) {
                Text("EN").tag("en")
                Text("ES").tag("es")
            }
            .pickerStyle(.wheel)
            if let errorText {
                Text(errorText)
                    .font(.footnote)
                    .foregroundStyle(.red)
            } else if let first = prayers.first {
                Text(first.title)
                    .font(.caption)

                Button(isSpeaking ? "Speaking…" : "Speak") {
                    speak(first)
                }
                .disabled(isSpeaking)
            } else {
                Text("Loading…")
                    .font(.caption)
            }
        }
        .padding()
        .onAppear {
            do {
                prayers = try PrayerStore.load()
            } catch {
                errorText = error.localizedDescription
            }
        }
    }

    private func speak(_ prayer: Prayer) {
        let text = prayer.translations[lang] ?? prayer.translations["en"] ?? ""
        guard !text.isEmpty else { return }

        isSpeaking = true

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: lang == "es" ? "es-MX" : "en-US")
        utterance.rate = 0.45

        synthesizer.speak(utterance)

        // temporary: re-enable after a bit (we'll make it exact with delegate next)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            isSpeaking = false
        }
    }
}

#Preview {
    ContentView()
}
