import SwiftUI

struct PrayerLibraryView: View {

    @State private var prayers: [Prayer] = []
    @State private var massPrayers: [Prayer] = []
    @State private var errorText: String?
    @State private var detailPrayer: Prayer?

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
                /// Same row control and scroll layout as home + `RosaryView.mysteryPicker` (full-width `DivinityPickerRowButton`, not `List`).
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if !massPrayers.isEmpty {
                            librarySectionHeader("Mass")
                            ForEach(massPrayers) { prayer in
                                DivinityPickerRowButton(
                                    icon: "building.columns",
                                    title: prayer.title,
                                    subtitle: "Mass",
                                    action: { detailPrayer = prayer }
                                )
                            }
                        }
                        if !catalogPrayersExcludingMass.isEmpty {
                            librarySectionHeader(massPrayers.isEmpty ? "Prayers" : "More prayers")
                            ForEach(catalogPrayersExcludingMass) { prayer in
                                DivinityPickerRowButton(
                                    icon: "book.pages",
                                    title: prayer.title,
                                    subtitle: "Listen",
                                    action: { detailPrayer = prayer }
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .scrollIndicators(.hidden)
            }
            }
        }
        .navigationDestination(item: $detailPrayer) { prayer in
            PrayerDetailView(prayer: prayer)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if speech.isSpeaking || speech.isPaused {
                PrayerLibraryDockedMiniPlayer(speech: speech)
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

    private func librarySectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold, design: .default))
            .foregroundStyle(accent.opacity(0.95))
            .textCase(.uppercase)
            .tracking(0.6)
            .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - Prayer playback UI (Spotify-on-Watch inspired)

private struct PrayerPlaybackProgressBar: View {
    @ObservedObject var speech: SpeechManager
    var accent: Color
    var height: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.12))
                Capsule()
                    .fill(accent)
                    .frame(width: max(2, geo.size.width * min(1, max(0, speech.playbackProgress))))
            }
            .frame(width: geo.size.width, height: height, alignment: .leading)
        }
        .frame(height: height)
    }
}

/// Bottom-docked bar: thumbnail, title / subtitle, stop + play (library list stays full height above).
private struct PrayerLibraryDockedMiniPlayer: View {
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
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 0.5)

            HStack(alignment: .center, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(accent.opacity(reduceTransparency ? 0.4 : 0.34))
                        .frame(width: 36, height: 36)
                    Image(systemName: artworkSymbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .symbolRenderingMode(.monochrome)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayTitle)
                        .font(.system(size: 12, weight: .semibold, design: .default))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    if let displaySubtitle {
                        Text(displaySubtitle)
                            .font(.system(size: 10, weight: .medium, design: .default))
                            .foregroundStyle(.white.opacity(0.52))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    speech.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.88))
                        .symbolRenderingMode(.monochrome)
                        .frame(width: 32, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Stop")
                .accessibilityIdentifier("TransportStop")

                Button {
                    if speech.isSpeaking {
                        speech.pause()
                    } else {
                        speech.resume()
                    }
                } label: {
                    Image(systemName: speech.isSpeaking ? "pause.fill" : "play.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                        .symbolRenderingMode(.monochrome)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(speech.isSpeaking ? "Pause" : "Play")
                .accessibilityIdentifier("TransportPlayPause")
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 6)

            PrayerPlaybackProgressBar(speech: speech, accent: accent, height: 2)
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(surface)
    }
}

/// Full-screen style hero: large square “art”, centered type, progress, three white controls (rewind / play / stop).
private struct PrayerDetailNowPlayingHero: View {
    @ObservedObject var speech: SpeechManager

    @Environment(\.appColorTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    private var accent: Color {
        theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
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
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(accent.opacity(reduceTransparency ? 0.4 : 0.34))
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 118)

                Image(systemName: artworkSymbol)
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolRenderingMode(.monochrome)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)

            Text(displayTitle)
                .font(.system(size: 15, weight: .bold, design: .default))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity)

            if let displaySubtitle {
                Text(displaySubtitle)
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }

            PrayerPlaybackProgressBar(speech: speech, accent: accent, height: 3)
                .padding(.horizontal, 6)

            HStack(spacing: 0) {
                Button {
                    speech.replayFromStart()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(.white.opacity(speech.canReplayCurrentUtterance ? 0.95 : 0.35))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!speech.canReplayCurrentUtterance)
                .accessibilityLabel("From beginning")
                .accessibilityIdentifier("TransportReplay")

                Spacer(minLength: 4)

                Button {
                    if speech.isSpeaking {
                        speech.pause()
                    } else {
                        speech.resume()
                    }
                } label: {
                    Image(systemName: speech.isSpeaking ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white)
                        .symbolRenderingMode(.monochrome)
                        .frame(width: 52, height: 52)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(speech.isSpeaking ? "Pause" : "Play")
                .accessibilityIdentifier("TransportPlayPause")

                Spacer(minLength: 4)

                Button {
                    speech.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(.white.opacity(0.95))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Stop")
                .accessibilityIdentifier("TransportStop")
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 8)
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
            VStack(alignment: .leading, spacing: 12) {
                if speech.isSpeaking || speech.isPaused {
                    PrayerDetailNowPlayingHero(speech: speech)
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
