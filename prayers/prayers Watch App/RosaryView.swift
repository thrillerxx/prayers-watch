import SwiftUI

struct RosaryView: View {
    @State private var prayersById: [String: Prayer] = [:]
    @State private var errorText: String?

    // v1: English-only until Spanish copy is verified.
    private let lang: String = "en"

    @State private var selectedMystery: RosaryMystery? = nil
    @State private var steps: [RosaryStep] = []
    @State private var index: Int = 0

    @State private var autoAdvance: Bool = true

    @StateObject private var speech = SpeechManager()

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

                Toggle("Auto", isOn: $autoAdvance)
                    .toggleStyle(.switch)

                HStack {
                    Button("Back") { back() }
                        .disabled(index == 0 || speech.isSpeaking)

                    Button(speech.isSpeaking ? "Stop" : "Speak") {
                        if speech.isSpeaking {
                            speech.stop()
                        } else {
                            speakCurrent()
                        }
                    }
                    .disabled(currentText == nil)

                    Button("Next") { next() }
                        .disabled(index >= steps.count - 1 || speech.isSpeaking)
                }

                Button("Change Mystery") {
                    selectedMystery = nil
                    steps = []
                    index = 0
                    speech.stop()
                }
                .buttonStyle(.bordered)
                .disabled(speech.isSpeaking)
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
            guard let prayer = prayersById[prayerId] else {
                return "[Missing prayer: \(prayerId)]"
            }
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

    private func speakCurrent() {
        guard let text = currentText, !text.isEmpty else { return }
        speech.speak(text: text, voiceLanguage: "en-US", rate: 0.45) {
            if autoAdvance, index < steps.count - 1 {
                index += 1
                speakCurrent()
            }
        }
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
