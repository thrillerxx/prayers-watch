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
        ZStack {
            DivinityMysteryHeroBackdrop()
            List {
                Section {
                    Picker("Color theme", selection: $colorThemeRaw) {
                        ForEach(AppColorTheme.allCases) { t in
                            Text(t.displayName).tag(t.rawValue)
                        }
                    }
                    .font(DivinityPickerRow.titleFont)
                } header: {
                    settingsSectionHeader("Appearance")
                }

                Section {
                    Toggle("Auto-advance", isOn: $autoAdvance)
                        .font(DivinityPickerRow.titleFont)
                    Toggle("Haptics", isOn: $haptics)
                        .font(DivinityPickerRow.titleFont)
                    Toggle("Fatima after each decade", isOn: $includeFatima)
                        .font(DivinityPickerRow.titleFont)
                    Toggle("St. Joseph after Rosary", isOn: $includeStJoseph)
                        .font(DivinityPickerRow.titleFont)
                    Text("Long-press the title on the Rosary screen to choose another mystery.")
                        .font(DivinityPickerRow.subtitleFont)
                        .foregroundStyle(.secondary)
                } header: {
                    settingsSectionHeader("Rosary")
                }

                Section {
                    Picker("Voice", selection: $voiceLanguage) {
                        Text("English (US)").tag("en-US")
                        Text("English (UK)").tag("en-GB")
                    }
                    .font(DivinityPickerRow.titleFont)

                    Picker("Speech Speed", selection: $speechSpeed) {
                        Text("Very Slow").tag("veryslow")
                        Text("Slow").tag("slow")
                        Text("Normal").tag("normal")
                    }
                    .font(DivinityPickerRow.titleFont)

                    HStack(spacing: 6) {
                        Text("Pause")
                            .font(DivinityPickerRow.titleFont)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 6) {
                            Button {
                                pauseBetweenPartsSeconds = max(1, pauseBetweenPartsSeconds - 1)
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            .buttonStyle(.plain)
                            .tint(accent)

                            Text("\(pauseBetweenPartsSeconds)s")
                                .font(DivinityPickerRow.subtitleFont)
                                .monospacedDigit()
                                .frame(minWidth: 30, alignment: .center)

                            Button {
                                pauseBetweenPartsSeconds = min(10, pauseBetweenPartsSeconds + 1)
                            } label: {
                                Image(systemName: "plus.circle")
                            }
                            .buttonStyle(.plain)
                            .tint(accent)
                        }
                    }
                    .contentShape(Rectangle())
                } header: {
                    settingsSectionHeader("Speech")
                }

                Section {
                    Text("Add the Divinity complication to your watch face for quick access.")
                        .font(DivinityPickerRow.subtitleFont)
                        .foregroundStyle(.secondary)
                } header: {
                    settingsSectionHeader("Watch face")
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(accent)
    }

    private func settingsSectionHeader(_ text: String) -> some View {
        Text(text)
            .font(DivinityMenuSection.labelFont)
            .foregroundStyle(accent.opacity(0.95))
            .textCase(.uppercase)
            .tracking(0.6)
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
