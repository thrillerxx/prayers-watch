import SwiftUI

struct RosaryView: View {

    @EnvironmentObject private var rosary: RosarySessionController
    @Binding var rosaryScreenActive: Bool

    @Environment(\.appColorTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    @ObservedObject private var speech = SpeechManager.shared

    private var solidChrome: Bool {
        reduceTransparency || differentiateWithoutColor
    }

    private var increaseContrast: Bool {
        differentiateWithoutColor
    }

    /// Readable on full-bleed art: light text + shadow; falls back to solid card when a11y needs it.
    private var heroPrimaryText: Color {
        solidChrome ? Color.primary : Color.white
    }

    private var heroSecondaryText: Color {
        solidChrome ? Color.secondary : Color.white.opacity(0.78)
    }

    var body: some View {
        Group {
            if let errorText = rosary.errorText {
                ZStack {
                    DivinityChrome.canvasBackground.ignoresSafeArea()
                    Text(errorText)
                        .font(DivinityFont.caption(11))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.horizontal, 10)
                }
            } else if rosary.selectedMystery == nil {
                mysteryPicker
            } else {
                nowPlayingSession
            }
        }
        .navigationTitle("Rosary")
        .navigationBarTitleDisplayMode(.inline)
        .tint(theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: increaseContrast))
        .onAppear {
            rosaryScreenActive = true
            rosary.loadPrayers()
            rosary.autostartIfRequested()
        }
        .onDisappear {
            rosaryScreenActive = false
        }
    }

    private var mysteryPicker: some View {
        let accent = theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: increaseContrast)
        let surface = DivinityChrome.elevatedSurface(theme: theme, reduceTransparency: reduceTransparency, increaseContrast: increaseContrast)
        let stroke = DivinityChrome.elevatedSurfaceStroke(theme: theme, accent: accent, reduceTransparency: reduceTransparency)

        return ZStack {
            DivinityChrome.canvasBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Rosary")
                            .font(DivinityFont.chrome(17))
                            .foregroundStyle(.primary)
                        Text("Choose a mystery set")
                            .font(DivinityFont.caption(11))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                    .padding(.bottom, 2)

                    ForEach(RosaryMystery.allCases) { mystery in
                        mysterySetPickerRow(
                            mystery: mystery,
                            accent: accent,
                            surface: surface,
                            stroke: stroke
                        ) {
                            rosary.start(mystery)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func mysterySetPickerRow(
        mystery: RosaryMystery,
        accent: Color,
        surface: Color,
        stroke: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(accent.opacity(reduceTransparency ? 0.28 : 0.22))
                        .frame(width: 40, height: 40)
                    Image(systemName: mysteryPickerIcon(mystery))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(accent)
                        .symbolRenderingMode(.monochrome)
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(mystery.title)
                        .font(DivinityFont.title(14))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .multilineTextAlignment(.leading)
                    Text(mysteryPickerSubtitle(mystery))
                        .font(DivinityFont.caption(11))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.88)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "play.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(accent.opacity(0.9))
                    .frame(width: 16, height: 16)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(stroke, lineWidth: 0.5)
                    }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mystery.title)
    }

    private func mysteryPickerIcon(_ mystery: RosaryMystery) -> String {
        switch mystery {
        case .joyful: return "gift.fill"
        case .sorrowful: return "cross.fill"
        case .glorious: return "sunrise.fill"
        case .luminous: return "sparkles"
        }
    }

    private func mysteryPickerSubtitle(_ mystery: RosaryMystery) -> String {
        switch mystery {
        case .joyful: return "Annunciation to the Temple"
        case .sorrowful: return "The Lord’s Passion"
        case .glorious: return "Resurrection & glory"
        case .luminous: return "The mysteries of light"
        }
    }

    private var nowPlayingSession: some View {
        ZStack {
            if rosary.selectedMystery != nil {
                mysteryHeroBackground
            }

            VStack(spacing: 0) {
                sessionHeader
                    .padding(.horizontal, 10)
                    .padding(.top, 6)
                    .padding(.bottom, 6)

                currentPrayerPanel
                    .padding(.horizontal, 8)

                Spacer(minLength: 0)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                playerChrome
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var mysteryHeroBackground: some View {
        Group {
            if let mystery = rosary.selectedMystery {
                let name = MysteryArt.assetName(mystery: mystery, stepIndex: rosary.index, steps: rosary.steps)
                let colors = theme.heroGradientColors(reduceTransparency: reduceTransparency, increaseContrast: increaseContrast)

                ZStack {
                    Image(name)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()

                    LinearGradient(
                        colors: colors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .allowsHitTesting(false)
                }
                .ignoresSafeArea()
            }
        }
    }

    private var sessionHeader: some View {
        VStack(alignment: .center, spacing: 4) {
            if let mystery = rosary.selectedMystery {
                Text(mystery.title)
                    .font(DivinityFont.caption(10))
                    .foregroundStyle(heroSecondaryText)
                    .textCase(.uppercase)
                    .tracking(0.4)
                    .shadow(color: textShadowColor, radius: solidChrome ? 0 : 2, x: 0, y: 1)
            }

            Text(rosary.displayTitle)
                .font(DivinityFont.title(14))
                .foregroundStyle(heroPrimaryText)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .lineSpacing(2)
                .minimumScaleFactor(0.82)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .center)
                .shadow(color: textShadowColor, radius: solidChrome ? 0 : 3, x: 0, y: 1)

            if let label = rosary.hailMaryCounterLabel {
                Text(label)
                    .font(DivinityFont.caption(11))
                    .fontWeight(.semibold)
                    .foregroundStyle(heroSecondaryText)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .shadow(color: textShadowColor, radius: solidChrome ? 0 : 2, x: 0, y: 1)
            }
        }
        .onLongPressGesture(minimumDuration: 0.55) {
            Task { @MainActor in
                rosary.exitToMysteryPicker()
            }
        }
    }

    private var textShadowColor: Color {
        solidChrome ? .clear : Color.black.opacity(0.45)
    }

    /// Single “now playing” prayer — avoids a long wall of dimmed sections (unreadable on watch).
    private var currentPrayerPanel: some View {
        let bodyText = rosary.textForStep(at: rosary.index) ?? ""

        return ScrollView {
            Text(bodyText)
                .font(DivinityFont.prayerEmphasis(15))
                .foregroundStyle(heroPrimaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(prayerCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color.black.opacity(solidChrome ? 0 : 0.35), radius: 8, x: 0, y: 3)
        }
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private var prayerCardBackground: some View {
        if solidChrome {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.regularMaterial)
        } else {
            ZStack {
                Color.black.opacity(0.38)
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
    }

    private var playerChrome: some View {
        let accent = theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: increaseContrast)

        return VStack(alignment: .leading, spacing: 8) {
            progressSection(accent: accent)

            HStack(spacing: 8) {
                Button {
                    rosary.previousStep()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.body.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(accent)
                .disabled(rosary.index == 0)
                .accessibilityLabel("Previous")
                .accessibilityIdentifier("TransportPrevious")

                Button {
                    rosary.playPauseTapped()
                } label: {
                    Image(systemName: speech.isSpeaking ? "pause.fill" : "play.fill")
                        .font(.body.weight(.semibold))
                        .frame(width: 40, height: 40)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(accent)
                .accessibilityIdentifier("TransportPlayPause")

                Button {
                    rosary.nextStep()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.body.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 2)
                }
                .buttonStyle(.bordered)
                .tint(accent)
                .disabled(rosary.steps.isEmpty || rosary.index >= rosary.steps.count - 1)
                .accessibilityLabel("Next")
                .accessibilityIdentifier("TransportNext")
            }

            Button {
                Task { @MainActor in rosary.stopPlayback() }
            } label: {
                Label("Stop", systemImage: "stop.fill")
                    .font(DivinityFont.caption(13))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(accent)
            .accessibilityIdentifier("TransportStop")
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(chromeBackground)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(accent.opacity(reduceTransparency ? 0.22 : 0.35))
                .frame(height: 0.5)
        }
    }

    @ViewBuilder
    private var chromeBackground: some View {
        if solidChrome {
            Color.black.opacity(0.92)
        } else {
            ZStack {
                Color.black.opacity(0.25)
                Rectangle().fill(.ultraThinMaterial)
            }
        }
    }

    private func progressSection(accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let decade = rosary.decadeProgressFraction() {
                Text("Decade")
                    .font(DivinityFont.caption(9))
                    .foregroundStyle(.tertiary)
                ThinProgressBar(value: decade, accent: accent)
            }

            Text("Rosary")
                .font(DivinityFont.caption(9))
                .foregroundStyle(.tertiary)
            ThinProgressBar(value: rosary.overallProgressFraction, accent: accent)
        }
    }

    private struct ThinProgressBar: View {
        let value: Double
        let accent: Color

        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.22))
                    Capsule()
                        .fill(accent)
                        .frame(width: max(3, geo.size.width * min(1, max(0, value))))
                }
            }
            .frame(height: 3)
        }
    }
}

#Preview {
    NavigationStack {
        RosaryView(rosaryScreenActive: .constant(true))
            .environmentObject(RosarySessionController())
    }
}
