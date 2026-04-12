import SwiftUI

struct SettingsView: View {

    @AppStorage(AppSettings.voiceLanguageKey) private var voiceLanguage: String = AppSettings.defaultVoiceLanguage

    @AppStorage(AppSettings.speechSpeedKey) private var speechSpeed: String = AppSettings.defaultSpeechSpeed
    @AppStorage(AppSettings.pauseBetweenPartsKey) private var pauseBetweenPartsSeconds: Int = AppSettings.defaultPauseBetweenPartsSeconds

    @AppStorage(AppSettings.autoAdvanceKey) private var autoAdvance: Bool = AppSettings.defaultAutoAdvance
    @AppStorage(AppSettings.hapticsKey) private var haptics: Bool = AppSettings.defaultHaptics
    @AppStorage(AppSettings.includeFatimaKey) private var includeFatima: Bool = AppSettings.defaultIncludeFatima
    @AppStorage(AppSettings.includeStJosephKey) private var includeStJoseph: Bool = AppSettings.defaultIncludeStJoseph

    @AppStorage(AppSettings.colorThemeKey) private var colorThemeRaw: String = AppSettings.defaultColorTheme

    @Environment(\.appColorTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    private var accent: Color {
        theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
    }

    var body: some View {
        List {
            Section("Appearance") {
                Picker("Color theme", selection: $colorThemeRaw) {
                    ForEach(AppColorTheme.allCases) { t in
                        Text(t.displayName).tag(t.rawValue)
                    }
                }
                .font(DivinityFont.caption(14))
            }

            Section("Rosary") {
                Toggle("Auto-advance", isOn: $autoAdvance)
                Toggle("Haptics", isOn: $haptics)
                Toggle("Fatima after each decade", isOn: $includeFatima)
                Toggle("St. Joseph after Rosary", isOn: $includeStJoseph)
                Text("Long-press the title on the Rosary screen to choose another mystery.")
                    .font(DivinityFont.caption(11))
                    .foregroundStyle(.secondary)
            }

            Section("Speech") {
                Picker("Voice", selection: $voiceLanguage) {
                    Text("English (US)").tag("en-US")
                    Text("English (UK)").tag("en-GB")
                }
                .font(DivinityFont.caption(14))

                Picker("Speech Speed", selection: $speechSpeed) {
                    Text("Very Slow").tag("veryslow")
                    Text("Slow").tag("slow")
                    Text("Normal").tag("normal")
                }
                .font(DivinityFont.caption(14))

                HStack(spacing: 8) {
                    Text("Pause")
                        .font(DivinityFont.caption(14))
                        .lineLimit(1)

                    Spacer(minLength: 6)

                    Button {
                        pauseBetweenPartsSeconds = max(1, pauseBetweenPartsSeconds - 1)
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .buttonStyle(.plain)
                    .tint(accent)

                    Text("\(pauseBetweenPartsSeconds)s")
                        .font(DivinityFont.caption(14))
                        .monospacedDigit()
                        .frame(minWidth: 28, alignment: .center)

                    Button {
                        pauseBetweenPartsSeconds = min(10, pauseBetweenPartsSeconds + 1)
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(.plain)
                    .tint(accent)
                }
                .contentShape(Rectangle())
            }

            Section {
                Text("Add the Divinity complication to your watch face for quick access.")
                    .font(DivinityFont.caption(11))
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .tint(accent)
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
