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

    // v1: English-only until Spanish copy is verified.
    private let lang: String = "en"

    @State private var selectedMystery: RosaryMystery? = nil
    @State private var steps: [RosaryStep] = []
    @State private var index: Int = 0

    @State private var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()
    private let delegate = RosarySpeechDelegate()

    var body: some View {
        VStack(spacing: 10) {
            if let errorText {
                Text(errorText)
                    .font(.footnote)
                    .foregroundStyle(.red)
            } else if selectedMystery == nil {
                Text("Choose Mystery")
                    .font(.headline)

                List {
                    ForEach(RosaryMystery.allCases) { mystery in
                        Button {
                            start(mystery)
                        } label: {
                            Text(mystery.title)
                        }
                    }
                }
            } else {
                Text(currentStep?.title ?? "Rosary")
                    .font(.headline)

                Text(currentText ?? "")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(8)

                HStack {
                    Button("Back") { back() }
                        .disabled(index == 0 || isSpeaking)

                    Button(isSpeaking ? "Speaking…" : "Speak") { speak() }
                        .disabled(isSpeaking || currentText == nil)

                    Button("Next") { next() }
                        .disabled(index >= steps.count - 1 || isSpeaking)
                }

                Button("Change Mystery") {
                    selectedMystery = nil
                    steps = []
                    index = 0
                }
                .buttonStyle(.bordered)
                .disabled(isSpeaking)
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

    private var currentText: String? {
        guard let step = currentStep else { return nil }
        switch step.content {
        case .text(let t):
            return t
        case .prayerId(let prayerId):
            guard let prayer = prayersById[prayerId] else { return nil }
            return prayer.translations[lang] ?? prayer.translations["en"]
        }
    }

    private func start(_ mystery: RosaryMystery) {
        selectedMystery = mystery
        steps = RosaryScripts.full(mystery: mystery)
        index = 0
    }

    private func loadPrayers() {
        do {
            let prayers = try PrayerStore.load()
            prayersById = Dictionary(uniqueKeysWithValues: prayers.map { ($0.id, $0) })
        } catch {
            errorText = error.localizedDescription
        }
    }

    private func speak() {
        guard let text = currentText, !text.isEmpty else { return }
        isSpeaking = true

        delegate.onFinish = {
            DispatchQueue.main.async {
                isSpeaking = false
            }
        }
        synthesizer.delegate = delegate

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45
        synthesizer.speak(utterance)
    }

    private func back() {
        index = max(0, index - 1)
    }

    private func next() {
        index = min(steps.count - 1, index + 1)
    }
}

#Preview {
    NavigationStack {
        RosaryView()
    }
}
