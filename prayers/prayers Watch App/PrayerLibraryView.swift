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
                PrayerPlaybackMiniPlayer(speech: speech)
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
                                .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
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
                                .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            }
                        } header: {
                            Text(massPrayers.isEmpty ? "Prayers" : "More prayers")
                                .font(DivinityFont.caption(10))
                                .foregroundStyle(accent.opacity(0.95))
                                .textCase(.uppercase)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
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
        .toolbarBackground(DivinityChrome.canvasBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
                    .symbolRenderingMode(.monochrome)
            }
            .frame(width: 32, height: 32)

            Text(title)
                .font(DivinityFont.title(14))
                .lineLimit(3)
                .minimumScaleFactor(0.82)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
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

/// Spotify-style “now playing” strip for prayer TTS: artwork well (list icons), sans title stack, accent progress, white transport glyphs.
private struct PrayerPlaybackMiniPlayer: View {
    @ObservedObject var speech: SpeechManager

    @Environment(\.appColorTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    private var accent: Color {
        theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
    }

    private var surface: Color {
        DivinityChrome.elevatedSurface(theme: theme, reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
    }

    private var stroke: Color {
        DivinityChrome.elevatedSurfaceStroke(theme: theme, accent: accent, reduceTransparency: reduceTransparency)
    }

    private var displayTitle: String {
        let t = speech.nowPlayingTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return t.isEmpty ? "Now playing" : t
    }

    private var displaySubtitle: String? {
        let s = speech.nowPlayingSubtitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return s.isEmpty ? nil : s
    }

    private var artworkSymbol: String {
        speech.nowPlayingArtworkSymbol ?? "waveform"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(accent.opacity(reduceTransparency ? 0.38 : 0.32))
                        .frame(width: 48, height: 48)
                    Image(systemName: artworkSymbol)
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(.white)
                        .symbolRenderingMode(.monochrome)
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayTitle)
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                        .multilineTextAlignment(.leading)

                    if let displaySubtitle {
                        Text(displaySubtitle)
                            .font(.system(size: 11, weight: .medium, design: .default))
                            .foregroundStyle(.white.opacity(0.52))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            playbackProgressBar

            HStack(spacing: 0) {
                Button {
                    speech.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundStyle(.white.opacity(0.92))
                        .symbolRenderingMode(.monochrome)
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Stop")
                .accessibilityIdentifier("TransportStop")

                Spacer(minLength: 8)

                Button {
                    if speech.isSpeaking {
                        speech.pause()
                    } else {
                        speech.resume()
                    }
                } label: {
                    Image(systemName: speech.isSpeaking ? "pause.fill" : "play.fill")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(.white)
                        .symbolRenderingMode(.monochrome)
                        .frame(width: 48, height: 48)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(speech.isSpeaking ? "Pause" : "Play")
                .accessibilityIdentifier("TransportPlayPause")

                Spacer(minLength: 8)

                Color.clear
                    .frame(width: 40, height: 40)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(stroke, lineWidth: 0.5)
                }
        }
    }

    private var playbackProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.12))
                Capsule()
                    .fill(accent)
                    .frame(width: max(3, geo.size.width * min(1, max(0, speech.playbackProgress))))
            }
            .frame(width: geo.size.width, height: 3, alignment: .leading)
        }
        .frame(height: 3)
    }
}

struct PrayerDetailView: View {
    let prayer: Prayer
    private let lang: String = "en"

    /// watchOS navigation titles truncate poorly; keep a hard cap for 42mm.
    private static func navigationTitleForWatch(_ raw: String, limit: Int = 22) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.count > limit else { return t }
        let idx = t.index(t.startIndex, offsetBy: limit - 1)
        return String(t[..<idx]) + "…"
    }

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
                    PrayerPlaybackMiniPlayer(speech: speech)
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Self.navigationTitleForWatch(prayer.title))
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

        speech.speak(
            text: text,
            voiceLanguage: "en-US",
            rate: 0.45,
            title: prayer.title,
            artworkSymbol: prayer.id.hasPrefix("mass_") ? "building.columns" : "book.pages",
            subtitle: prayer.id.hasPrefix("mass_") ? "Mass" : "Prayer"
        )
    }
}

#Preview {
    NavigationStack {
        PrayerLibraryView()
    }
}
