import SwiftUI

struct SettingsView: View {
    @AppStorage(AppSettings.voiceLanguageKey) private var voiceLanguage: String = AppSettings.defaultVoiceLanguage

    @AppStorage(AppSettings.speechSpeedKey) private var speechSpeed: String = AppSettings.defaultSpeechSpeed
    @AppStorage(AppSettings.pauseBetweenPartsKey) private var pauseBetweenPartsSeconds: Int = AppSettings.defaultPauseBetweenPartsSeconds

    @AppStorage(AppSettings.autoAdvanceKey) private var autoAdvance: Bool = AppSettings.defaultAutoAdvance
    @AppStorage(AppSettings.hapticsKey) private var haptics: Bool = AppSettings.defaultHaptics

    var body: some View {
        List {
            Section("Rosary") {
                Toggle("Auto-advance", isOn: $autoAdvance)
                Toggle("Haptics", isOn: $haptics)
            }

            Section("Speech") {
                Picker("Voice", selection: $voiceLanguage) {
                    Text("English (US)").tag("en-US")
                    Text("English (UK)").tag("en-GB")
                }

                Picker("Speech Speed", selection: $speechSpeed) {
                    Text("Very Slow").tag("veryslow")
                    Text("Slow").tag("slow")
                    Text("Normal").tag("normal")
                }

                HStack {
                    Text("Pause Between Parts")
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Spacer()

                    Stepper(value: $pauseBetweenPartsSeconds, in: 1...10) {
                        Text("\(pauseBetweenPartsSeconds)s")
                            .monospacedDigit()
                    }
                    .labelsHidden()
                }
            }

            Section {
                Text("More settings + complications coming next.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
