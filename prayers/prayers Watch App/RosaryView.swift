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
        // Empty title: inline "Rosary" collided with hero typography and duplicated the picker header.
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(rosary.selectedMystery == nil ? DivinityChrome.canvasBackground : Color.clear, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
                    HStack {
                        Spacer(minLength: 0)
                        VStack(alignment: .center, spacing: 4) {
                            Text("Rosary")
                                .font(DivinityFont.chrome(17))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                            Text("Choose a set")
                                .font(DivinityFont.caption(11))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        Spacer(minLength: 0)
                    }
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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .symbolRenderingMode(.monochrome)
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 3) {
                    Text(mystery.title)
                        .font(DivinityFont.title(14))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .multilineTextAlignment(.leading)
                    Text(mysteryPickerSubtitle(mystery))
                        .font(DivinityFont.caption(10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "play.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(accent.opacity(0.9))
                    .frame(width: 16, height: 16)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 11)
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
        case .joyful: return "Incarnation"
        case .sorrowful: return "Passion"
        case .glorious: return "Glory"
        case .luminous: return "Light"
        }
    }

    private var nowPlayingSession: some View {
        ZStack(alignment: .bottom) {
            if rosary.selectedMystery != nil {
                mysteryHeroBackground
            }

            VStack(spacing: 0) {
                sessionHeader
                    .padding(.horizontal, 10)
                    .padding(.top, 8)
                    .padding(.bottom, 6)

                currentPrayerPanel
                    .padding(.horizontal, 8)

                Spacer()
                    .frame(minHeight: 136)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            playerChrome
                .frame(maxWidth: .infinity)
        }
    }

    /// Avoid a duplicate “Rosary” line; fall back to the step title when the controller returns the generic label.
    private var heroStepTitle: String? {
        let t = rosary.displayTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !t.isEmpty, t.caseInsensitiveCompare("Rosary") != .orderedSame {
            return t
        }
        if let stepTitle = rosary.currentStep?.title.trimmingCharacters(in: .whitespacesAndNewlines),
           !stepTitle.isEmpty,
           stepTitle.caseInsensitiveCompare("Rosary") != .orderedSame {
            return stepTitle
        }
        return nil
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
        VStack(alignment: .center, spacing: 8) {
            if let mystery = rosary.selectedMystery {
                Text(mystery.title)
                    .font(DivinityFont.caption(10))
                    .foregroundStyle(heroSecondaryText)
                    .textCase(.uppercase)
                    .tracking(0.4)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .shadow(color: textShadowColor, radius: solidChrome ? 0 : 2, x: 0, y: 1)
            }

            if let stepTitle = heroStepTitle {
                Text(stepTitle)
                    .font(DivinityFont.title(13))
                    .foregroundStyle(heroPrimaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .lineSpacing(2)
                    .minimumScaleFactor(0.7)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .shadow(color: textShadowColor, radius: solidChrome ? 0 : 3, x: 0, y: 1)
                    .padding(.horizontal, 4)
            }

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
        let surface = DivinityChrome.elevatedSurface(theme: theme, reduceTransparency: reduceTransparency, increaseContrast: increaseContrast)
        let stroke = DivinityChrome.elevatedSurfaceStroke(theme: theme, accent: accent, reduceTransparency: reduceTransparency)

        return VStack(alignment: .leading, spacing: 10) {
            progressSection(accent: accent)

            HStack(spacing: 2) {
                transportButton(
                    icon: "backward.fill",
                    accent: accent,
                    prominent: false,
                    disabled: rosary.index == 0,
                    action: { rosary.previousStep() }
                )
                .accessibilityLabel("Previous")
                .accessibilityIdentifier("TransportPrevious")
                .frame(maxWidth: .infinity)
                .frame(height: 34)

                transportButton(
                    icon: speech.isSpeaking ? "pause.fill" : "play.fill",
                    accent: accent,
                    prominent: true,
                    disabled: false,
                    action: { rosary.playPauseTapped() }
                )
                .accessibilityIdentifier("TransportPlayPause")
                .frame(maxWidth: .infinity)
                .frame(height: 34)

                transportButton(
                    icon: "forward.fill",
                    accent: accent,
                    prominent: false,
                    disabled: rosary.steps.isEmpty || rosary.index >= rosary.steps.count - 1,
                    action: { rosary.nextStep() }
                )
                .accessibilityLabel("Next")
                .accessibilityIdentifier("TransportNext")
                .frame(maxWidth: .infinity)
                .frame(height: 34)
            }

            Button {
                Task { @MainActor in rosary.stopPlayback() }
            } label: {
                Label("Stop", systemImage: "stop.fill")
                    .font(DivinityFont.caption(12))
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
            }
            .buttonStyle(.bordered)
            .tint(accent)
            .controlSize(.small)
            .accessibilityIdentifier("TransportStop")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background {
            playerChromeBackground(surface: surface, stroke: stroke)
        }
        .shadow(color: .black.opacity(solidChrome ? 0.28 : 0.38), radius: 10, x: 0, y: -4)
    }

    @ViewBuilder
    private func transportButton(
        icon: String,
        accent: Color,
        prominent: Bool,
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        if prominent {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 8))
            .controlSize(.mini)
            .tint(accent)
            .disabled(disabled)
        } else {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 8))
            .controlSize(.mini)
            .tint(accent)
            .disabled(disabled)
        }
    }

    @ViewBuilder
    private func playerChromeBackground(surface: Color, stroke: Color) -> some View {
        let topRadius: CGFloat = 18
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: topRadius,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: topRadius,
            style: .continuous
        )
        ZStack {
            if solidChrome {
                shape.fill(surface)
            } else {
                shape.fill(surface.opacity(0.92))
                shape.fill(.ultraThinMaterial)
            }
            shape.stroke(stroke, lineWidth: 0.5)
        }
    }

    private var playerProgressLabelColor: Color {
        solidChrome ? Color.secondary : Color.white.opacity(0.58)
    }

    private func progressSection(accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if let decade = rosary.decadeProgressFraction() {
                Text("Decade")
                    .font(DivinityFont.caption(9))
                    .fontWeight(.medium)
                    .foregroundStyle(playerProgressLabelColor)
                    .textCase(.uppercase)
                    .tracking(0.3)
                ThinProgressBar(value: decade, accent: accent, dimmed: !solidChrome)
            }

            Text("Rosary")
                .font(DivinityFont.caption(9))
                .fontWeight(.medium)
                .foregroundStyle(playerProgressLabelColor)
                .textCase(.uppercase)
                .tracking(0.3)
            ThinProgressBar(value: rosary.overallProgressFraction, accent: accent, dimmed: !solidChrome)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private struct ThinProgressBar: View {
        let value: Double
        let accent: Color
        var dimmed: Bool = false

        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(dimmed ? Color.white.opacity(0.14) : Color.secondary.opacity(0.22))
                    Capsule()
                        .fill(accent)
                        .frame(width: max(4, geo.size.width * min(1, max(0, value))))
                }
                .frame(width: geo.size.width, height: 4, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 4)
        }
    }
}

#Preview {
    NavigationStack {
        RosaryView(rosaryScreenActive: .constant(true))
            .environmentObject(RosarySessionController())
    }
}
