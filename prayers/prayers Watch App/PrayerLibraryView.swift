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
    @State private var isSpeaking = false
    @State private var speakingTitle: String?

    private let synthesizer = AVSpeechSynthesizer()
    private let speechDelegate = SpeechDelegate()

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
            } else {
                List(prayers) { prayer in
                    Button {
                        speak(prayer)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(prayer.title)
                            if isSpeaking, speakingTitle == prayer.title {
                                Text("Speaking…")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .disabled(isSpeaking)
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

    private func speak(_ prayer: Prayer) {
        let text = prayer.translations[lang] ?? prayer.translations["en"] ?? ""
        guard !text.isEmpty else { return }

        isSpeaking = true
        speakingTitle = prayer.title

        speechDelegate.onFinish = {
            DispatchQueue.main.async {
                isSpeaking = false
                speakingTitle = nil
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
