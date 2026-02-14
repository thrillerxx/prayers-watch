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

    @AppStorage("rosaryLang") private var lang: String = "en"
    @AppStorage("rosaryMysterySet") private var mysterySetRaw: String = MysterySet.joyful.rawValue
    @AppStorage("rosaryStepIndex") private var index: Int = 0

    @State private var steps: [RosaryStep] = []
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
                Picker("Mysteries", selection: $mysterySetRaw) {
                    ForEach(MysterySet.allCases) { set in
                        Text(set.rawValue).tag(set.rawValue)
                    }
                }

                Text(currentStep?.title ?? "Rosary")
                    .font(.headline)

                Text(currentText ?? "")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(6)

                HStack {
                    Button("Back") { back() }
                        .disabled(index == 0 || isSpeaking)

                    Button(isSpeaking ? "Speaking…" : (index == 0 ? "Start" : "Continue")) { startOrSpeak() }
                        .disabled(isSpeaking)

                    Button("Next") { skip() }
                        .disabled(index >= steps.count - 1 || isSpeaking)
                }

                Button("Restart") {
                    synthesizer.stopSpeaking(at: .immediate)
                    isSpeaking = false
                    index = 0
                }
                .font(.footnote)
                .disabled(isSpeaking)
            }
        }
        .padding()
        .navigationTitle("Rosary")
        .onAppear {
            loadPrayers()
            rebuildSteps(resetIndexIfNeeded: false)
        }
        .onChange(of: mysterySetRaw) { _, _ in
            rebuildSteps(resetIndexIfNeeded: true)
        }
    }

    private var selectedSet: MysterySet {
        MysterySet(rawValue: mysterySetRaw) ?? .joyful
    }

    private var currentStep: RosaryStep? {
        guard steps.indices.contains(index) else { return nil }
        return steps[index]
    }

    private var currentText: String? {
        guard let step = currentStep else { return nil }
        switch step.kind {
        case .announcement(let text):
            return text
        case .prayer(let id):
            guard let prayer = prayersById[id] else { return nil }
            return prayer.translations[lang] ?? prayer.translations["en"]
        }
    }

    private func loadPrayers() {
        do {
            let prayers = try PrayerStore.load()
            prayersById = Dictionary(uniqueKeysWithValues: prayers.map { ($0.id, $0) })
        } catch {
            errorText = error.localizedDescription
        }
    }

    private func rebuildSteps(resetIndexIfNeeded: Bool) {
        steps = RosaryScripts.full(set: selectedSet)
        if resetIndexIfNeeded {
            index = 0
        } else {
            // clamp persisted index if steps changed
            index = min(max(0, index), max(steps.count - 1, 0))
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
