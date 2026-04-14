import SwiftUI

struct PrayerLibraryView: View {

    @State private var prayers: [Prayer] = []
    @State private var massPrayers: [Prayer] = []
    @State private var errorText: String?

    @ObservedObject private var speech = SpeechManager.shared

    @Environment(\.appColorTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    private var accent: Color {
        theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
    }

    /// Catalog prayers excluding rows also listed under Mass (avoid duplicate rows).
    private var catalogPrayersExcludingMass: [Prayer] {
        let massIds = Set(massPrayers.map(\.id))
        return prayers.filter { !massIds.contains($0.id) }
    }

    var body: some View {
        ZStack {
            DivinityChrome.canvasBackground.ignoresSafeArea()
            VStack(spacing: 0) {
            if speech.isSpeaking || speech.isPaused {
                TransportRow(speech: speech, accent: accent)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6)
            }
            if let errorText {
                Text(errorText)
                    .font(DivinityFont.caption(11))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
            } else if prayers.isEmpty && massPrayers.isEmpty {
                Text("No prayers found")
                    .font(DivinityFont.caption(12))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            } else {
                List {
                    if !massPrayers.isEmpty {
                        Section {
                            ForEach(massPrayers) { prayer in
                                NavigationLink {
                                    PrayerDetailView(prayer: prayer)
                                } label: {
                                    prayerRowLabel(title: prayer.title, icon: "building.columns")
                                }
                            }
                        } header: {
                            Text("Mass")
                                .font(DivinityFont.caption(10))
                                .foregroundStyle(accent.opacity(0.95))
                                .textCase(.uppercase)
                        }
                    }

                    if !catalogPrayersExcludingMass.isEmpty {
                        Section {
                            ForEach(catalogPrayersExcludingMass) { prayer in
                                NavigationLink {
                                    PrayerDetailView(prayer: prayer)
                                } label: {
                                    prayerRowLabel(title: prayer.title, icon: "book.pages")
                                }
                            }
                        } header: {
                            Text(massPrayers.isEmpty ? "Prayers" : "More prayers")
                                .font(DivinityFont.caption(10))
                                .foregroundStyle(accent.opacity(0.95))
                                .textCase(.uppercase)
                        }
                    }
                }
                .listSectionSpacing(8)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(DivinityChrome.elevatedSurface(theme: theme, reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor))
                        .padding(.vertical, 2)
                )
            }
            }
        }
        .navigationTitle("Prayer Library")
        .navigationBarTitleDisplayMode(.inline)
        .tint(accent)
        .onAppear {
            loadPrayers()
        }
    }

    @ViewBuilder
    private func prayerRowLabel(title: String, icon: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(accent.opacity(reduceTransparency ? 0.28 : 0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accent)
            }
            Text(title)
                .font(DivinityFont.title(14))
                .lineLimit(3)
                .minimumScaleFactor(0.82)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }

    private func loadPrayers() {
        var errors: [String] = []

        do {
            prayers = try PrayerStore.load().filter { prayer in
                let id = prayer.id
                if id.hasPrefix("mysteryset_") { return false }
                if id.hasSuffix("_title") { return false }
                if id.hasSuffix("_alt_title") { return false }
                return true
            }
        } catch {
            prayers = []
            errors.append("Prayers: \(error.localizedDescription)")
        }

        do {
            massPrayers = try PrayerStore.loadMassPrayers()
        } catch {
            massPrayers = []
            errors.append("Mass Prayers: \(error.localizedDescription)")
        }

        errorText = errors.isEmpty ? nil : errors.joined(separator: "\n")
    }
}

private struct TransportRow: View {
    @ObservedObject var speech: SpeechManager
    var accent: Color

    var body: some View {
        HStack(spacing: 10) {
            Button {
                if speech.isSpeaking {
                    speech.pause()
                } else {
                    speech.resume()
                }
            } label: {
                Label(speech.isSpeaking ? "Pause" : "Play", systemImage: speech.isSpeaking ? "pause.fill" : "play.fill")
                    .font(DivinityFont.caption(13))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(accent)
            .accessibilityIdentifier("TransportPlayPause")

            Button {
                speech.stop()
            } label: {
                Image(systemName: "stop.fill")
            }
            .buttonStyle(.bordered)
            .tint(accent)
            .accessibilityIdentifier("TransportStop")
        }
    }
}

struct PrayerDetailView: View {
    let prayer: Prayer
    private let lang: String = "en"

    @ObservedObject private var speech = SpeechManager.shared

    @Environment(\.appColorTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    private var accent: Color {
        theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
    }

    @State private var didAutoplay = false

    private var text: String {
        prayer.translations[lang] ?? prayer.translations["en"] ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if speech.isSpeaking || speech.isPaused {
                    TransportRow(speech: speech, accent: accent)
                }

                if text.isEmpty {
                    Text("No text for this prayer in the selected language.")
                        .font(DivinityFont.caption(11))
                        .foregroundStyle(.secondary)
                } else {
                    Text(text)
                        .font(DivinityFont.prayer(14))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .navigationTitle(prayer.title)
        .navigationBarTitleDisplayMode(.inline)
        .tint(accent)
        .onAppear {
            if !didAutoplay {
                didAutoplay = true
                speech.stop()
                speak()
            }
        }
    }

    private func speak() {
        guard !text.isEmpty else { return }

        speech.speak(text: text, voiceLanguage: "en-US", rate: 0.45)
    }
}

#Preview {
    NavigationStack {
        PrayerLibraryView()
    }
}
