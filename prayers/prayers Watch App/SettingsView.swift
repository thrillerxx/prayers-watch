import SwiftUI

struct SettingsView: View {
    @AppStorage(AppSettings.voiceLanguageKey) private var voiceLanguage: String = AppSettings.defaultVoiceLanguage
    @AppStorage(AppSettings.speechRateKey) private var speechRate: Double = Double(AppSettings.defaultSpeechRate)

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
                    Text("Spanish").tag("es-ES")
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Rate")
                    Slider(value: $speechRate, in: 0.35...0.60, step: 0.01)
                    Text(String(format: "%.2f", speechRate))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
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
