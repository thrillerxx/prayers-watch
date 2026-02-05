import SwiftUI
import AVFoundation

final class RosarySpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    var onFinish: (() -> Void)?

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinish?()
    }
}

struct RosaryView: View {
    @State private var prayersById: [String: Prayer] = [:]
    @State private var errorText: String?

    @State private var lang: String = "en"
    @State private var steps: [RosaryStep] = RosaryScripts.opening
    @State private var index: Int = 0

    @State private var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()
    private let delegate = RosarySpeechDelegate()

    var body: some View {
        VStack(spacing: 10) {
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
            } else {
                Text(currentStep?.title ?? "Rosary")
                    .font(.headline)

                Text(currentText ?? "")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(6)

                HStack {
                    Button("Back") { back() }
                        .disabled(index == 0 || isSpeaking)

                    Button(isSpeaking ? "Speaking…" : "Start") { startOrSpeak() }
                        .disabled(isSpeaking)

                    Button("Skip") { skip() }
                        .disabled(index >= steps.count - 1 || isSpeaking)
                }
            }
        }
        .padding()
        .navigationTitle("Rosary")
        .onAppear { loadPrayers() }
    }

    private var currentStep: RosaryStep? {
        guard steps.indices.contains(index) else { return nil }
        return steps[index]
    }

    private var currentPrayer: Prayer? {
        guard let step = currentStep else { return nil }
        return prayersById[step.prayerId]
    }

    private var currentText: String? {
        guard let prayer = currentPrayer else { return nil }
        return prayer.translations[lang] ?? prayer.translations["en"]
    }

    private func loadPrayers() {
        do {
            let prayers = try PrayerStore.load()
            prayersById = Dictionary(uniqueKeysWithValues: prayers.map { ($0.id, $0) })
        } catch {
            errorText = error.localizedDescription
        }
    }

    private func startOrSpeak() {
        guard let text = currentText, !text.isEmpty else { return }
        isSpeaking = true

        delegate.onFinish = {
            DispatchQueue.main.async {
                isSpeaking = false
                // auto-advance
                if index < steps.count - 1 {
                    index += 1
                    startOrSpeak()
                }
            }
        }
        synthesizer.delegate = delegate

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: lang == "es" ? "es-MX" : "en-US")
        utterance.rate = 0.45
        synthesizer.speak(utterance)
    }

    private func back() {
        index = max(0, index - 1)
    }

    private func skip() {
        index = min(steps.count - 1, index + 1)
    }
}

#Preview {
    NavigationStack {
        RosaryView()
    }
}
