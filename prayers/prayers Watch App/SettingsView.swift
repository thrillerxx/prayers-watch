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

                HStack(spacing: 8) {
                    Text("Pause")
                        .lineLimit(1)

                    Spacer(minLength: 6)

                    Button {
                        pauseBetweenPartsSeconds = max(1, pauseBetweenPartsSeconds - 1)
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .buttonStyle(.plain)

                    Text("\(pauseBetweenPartsSeconds)s")
                        .monospacedDigit()
                        .frame(minWidth: 28, alignment: .center)

                    Button {
                        pauseBetweenPartsSeconds = min(10, pauseBetweenPartsSeconds + 1)
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(.plain)
                }
                .contentShape(Rectangle())
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
