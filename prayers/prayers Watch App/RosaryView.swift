import SwiftUI

struct RosaryView: View {
    @State private var prayersById: [String: Prayer] = [:]
    @State private var errorText: String?

    // v1: English-only until Spanish copy is verified.
    private let lang: String = "en"

    @State private var selectedMystery: RosaryMystery? = nil
    @State private var steps: [RosaryStep] = []
    @State private var index: Int = 0

    @AppStorage(AppSettings.autoAdvanceKey) private var autoAdvance: Bool = AppSettings.defaultAutoAdvance
    @AppStorage(AppSettings.hapticsKey) private var hapticsOn: Bool = AppSettings.defaultHaptics
    @AppStorage(AppSettings.voiceLanguageKey) private var voiceLanguage: String = AppSettings.defaultVoiceLanguage
    @AppStorage(AppSettings.speechSpeedKey) private var speechSpeed: String = AppSettings.defaultSpeechSpeed
    @AppStorage(AppSettings.pauseBetweenPartsKey) private var pauseBetweenPartsSeconds: Int = AppSettings.defaultPauseBetweenPartsSeconds

    @StateObject private var speech = SpeechManager.shared

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
                Text(displayTitle)
                    .font(.headline)
                    .padding(.top, 6)

                if let label = hailMaryCounterLabel {
                    Text(label)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }

                ScrollView {
                    Text(currentText ?? "")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                Toggle("Auto", isOn: $autoAdvance)
                    .toggleStyle(.switch)

                HStack {
                    Button("Back") { back() }
                        .disabled(index == 0 || speech.isSpeaking)

                    Button(speech.isSpeaking ? "Pause" : (speech.isPaused ? "Resume" : "Speak")) {
                        if speech.isSpeaking {
                            speech.pause()
                        } else if speech.isPaused {
                            speech.resume()
                        } else {
                            speakCurrent()
                        }
                    }
                    .disabled(currentText == nil)

                    Button("Next") { next() }
                        .disabled(index >= steps.count - 1)
                }
                .buttonStyle(.bordered)

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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPrayers()
            autostartIfRequested()
        }
    }

    private func autostartIfRequested() {
        // Allows automation without UI taps (e.g. simulator launches).
        // Usage: xcrun simctl launch ... --args --autoplay
        guard ProcessInfo.processInfo.arguments.contains("--autoplay") else { return }

        let mystery = RosaryMystery.defaultForToday()
        start(mystery)

        // Speak after state updates land
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            speakCurrent()
        }
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

    private var displayTitle: String {
        guard let step = currentStep else { return "Rosary" }
        // If this is a mystery meditation step, show the mystery title loaded from JSON.
        if case .prayerId(let prayerId) = step.content,
           prayerId.hasPrefix("mystery_"),
           prayerId.hasSuffix("_meditation") {
            let titleId = prayerId.replacingOccurrences(of: "_meditation", with: "_title")
            if let titlePrayer = prayersById[titleId],
               let t = titlePrayer.translations[lang] ?? titlePrayer.translations["en"],
               !t.isEmpty {
                return t
            }
        }
        return step.title
    }

    private var hailMaryCounterLabel: String? {
        guard let step = currentStep else { return nil }
        // Show counter only during the 10 Hail Mary steps of a decade.
        guard step.title == "Hail Mary" else { return nil }

        // Find the start of this decade's Hail Mary run by scanning backwards
        // until we hit the preceding Our Father.
        var startIndex = index
        while startIndex > 0 {
            let prev = steps[startIndex - 1]
            if prev.title == "Our Father" { break }
            // Stop if we hit another non-Hail Mary prayer (safety)
            if prev.title != "Hail Mary" { break }
            startIndex -= 1
        }

        let pos = (index - startIndex) + 1
        let total = 10
        let remaining = max(0, total - pos)
        if pos < 1 || pos > total { return nil }
        return "Hail Mary \(pos)/\(total)"
    }

    private func start(_ mystery: RosaryMystery) {
        selectedMystery = mystery
        steps = RosaryScripts.full(mystery: mystery)
        index = 0

        // Verification log: we expect 10 ids per set (5 titles + 5 meditations).
        let ids = (1...5).flatMap { i in
            [
                "mystery_\(mystery.contentKey)_\(i)_title",
                "mystery_\(mystery.contentKey)_\(i)_meditation"
            ]
        }
        print("[Mysteries] set=\(mystery.rawValue) count=\(ids.count) first=\(ids.first ?? "") last=\(ids.last ?? "")")
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

        let rate: Float
        switch speechSpeed {
        case "veryslow": rate = 0.35
        case "slow": rate = 0.42
        default: rate = 0.50 // normal
        }

        speech.speak(text: text, voiceLanguage: voiceLanguage, rate: rate) {
            guard autoAdvance else {
                if index >= steps.count - 1, hapticsOn { Haptics.success() }
                return
            }

            if index < steps.count - 1 {
                index += 1
                if hapticsOn { Haptics.click() }

                let delay = Double(max(1, min(10, pauseBetweenPartsSeconds)))
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    speakCurrent()
                }
            } else {
                if hapticsOn { Haptics.success() }
            }
        }
    }

    private func back() {
        index = max(0, index - 1)
        if hapticsOn { Haptics.click() }
    }

    private func next() {
        // Always stop current utterance and advance immediately.
        if speech.isSpeaking || speech.isPaused {
            speech.stop()
        }

        index = min(steps.count - 1, index + 1)
        if hapticsOn { Haptics.click() }

        // If auto mode is enabled, immediately start speaking the new step.
        if autoAdvance {
            DispatchQueue.main.async {
                speakCurrent()
            }
        }
    }
}

#Preview {
    NavigationStack {
        RosaryView()
    }
}
