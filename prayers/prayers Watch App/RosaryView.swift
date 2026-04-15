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

    /// App-icon gold (#F9E29C → #B8860B) for rosary controls (transport + top Back/Stop).
    private var rosaryBrandGoldLight: Color { Color(red: 0.976, green: 0.886, blue: 0.612) }
    private var rosaryBrandGoldDark: Color { Color(red: 0.722, green: 0.525, blue: 0.043) }

    private var rosaryControlGoldGradient: LinearGradient {
        LinearGradient(
            colors: [rosaryBrandGoldLight, rosaryBrandGoldDark],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// SF Symbol tint on glass; darker gold on solid chrome for contrast.
    private var rosaryControlButtonForeground: Color {
        solidChrome ? Color(red: 0.45, green: 0.32, blue: 0.08) : rosaryBrandGoldLight
    }

    /// Progress / filled controls on hero (single mid-gold reads well on dark scrim).
    private var rosaryControlAccentColor: Color {
        Color(red: 0.88, green: 0.72, blue: 0.38)
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
        .toolbar(rosary.selectedMystery != nil ? .hidden : .automatic, for: .navigationBar)
        .navigationBarBackButtonHidden(rosary.selectedMystery != nil)
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

    /// Choosing a set should open the session and begin audio (matches “tap row → plays” expectation).
    private func pickMystery(_ mystery: RosaryMystery) {
        rosary.start(mystery)
        rosary.transition(to: 0, reason: .manualStart)
    }

    private var mysteryPicker: some View {
        let accent = theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: increaseContrast)

        return ZStack {
            DivinityChrome.canvasBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .center, spacing: 6) {
                        Text("Mysteries")
                            .font(.system(size: 10, weight: .semibold, design: .default))
                            .foregroundStyle(accent.opacity(0.95))
                            .textCase(.uppercase)
                            .tracking(0.6)
                        Text("Rosary")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                        Text("Choose a set to begin")
                            .font(DivinityPickerRow.subtitleFont)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                    .padding(.bottom, 4)

                    ForEach(RosaryMystery.allCases) { mystery in
                        mysterySetPickerRow(mystery: mystery) {
                            pickMystery(mystery)
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

    private func mysterySetPickerRow(mystery: RosaryMystery, action: @escaping () -> Void) -> some View {
        DivinityPickerRowButton(
            icon: mysteryPickerIcon(mystery),
            title: mystery.title,
            subtitle: mysteryPickerSubtitle(mystery),
            action: action
        )
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

    /// Music-style layout: blurred hero, small cover art; prayer scrolls full-width with controls overlaid (no text card).
    private var nowPlayingSession: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                WatchMediaTimeSuppressor()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)

                if rosary.selectedMystery != nil {
                    mysteryHeroBackground
                }

                ScrollView {
                    VStack(spacing: 10) {
                        Color.clear.frame(height: 4)
                        rosaryAlbumArtTile
                        rosarySessionTitles
                            .onLongPressGesture(minimumDuration: 0.55) {
                                Task { @MainActor in
                                    rosary.exitToMysteryPicker()
                                }
                            }
                        rosaryPrayerBody
                    }
                    .padding(.horizontal, rosaryReadableWidthInset(watchWidth: geo.size.width))
                    .padding(.top, rosaryNowPlayingScrollTopInset(watchWidth: geo.size.width))
                    .padding(.bottom, 74)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollIndicators(.hidden)
                .overlay(alignment: .top) {
                    rosaryMusicTopChrome(watchWidth: geo.size.width)
                        .ignoresSafeArea(edges: .top)
                }

                rosaryFloatingPlayerChrome
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        /// Apply on the now-playing subtree (not the whole `RosaryView`); corner clock still appeared on 46mm when this lived on the outer `Group`.
        /// Uses underscored SPI; ineffective on some OS builds — then only VideoPlayer/Now Playing mitigations apply.
        ._statusBarHidden(true)
        #if DEBUG
        .onAppear {
            print("[Rosary] nowPlayingSession active — expect _statusBarHidden(true) on this screen")
        }
        #endif
    }

    /// Keeps scroll content below the floating top chrome (time + Back/Stop) on 42mm / 46mm.
    private func rosaryNowPlayingScrollTopInset(watchWidth: CGFloat) -> CGFloat {
        /// Keep scroll content below top chrome; grows when chrome sits lower (`topPad`).
        watchWidth >= 200 ? 85 : 69
    }

    /// Horizontal inset so titles and prayer text stay inside the round watch mask.
    private func rosaryReadableWidthInset(watchWidth: CGFloat) -> CGFloat {
        max(22, (watchWidth * 0.175).rounded(.down))
    }

    /// Top bar: time on the first row; back and Stop on the second row at left/right, inset from the curved bezel.
    private func rosaryMusicTopChrome(watchWidth: CGFloat) -> some View {
        let isLargeWatch = watchWidth >= 200
        /// Whole-chrome vertical offset; 42mm time-only shift uses `offset` below so Back/Stop stay put.
        let topPad: CGFloat = isLargeWatch ? 10 : 0
        let smallWatchTimeDrop: CGFloat = isLargeWatch ? 0 : 7
        /// Round watch face clips rectangular layout; keep controls clearly inside the circular mask.
        let edgeInset: CGFloat = max(isLargeWatch ? 52 : 48, (watchWidth * 0.29).rounded(.down))
        let chromeButtonSize: CGFloat = isLargeWatch ? 32 : 30

        return VStack(alignment: .center, spacing: 0) {
            TimelineView(.periodic(from: .now, by: 60.0)) { context in
                Text(context.date, format: .dateTime.hour().minute())
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundStyle(heroPrimaryText)
                    .monospacedDigit()
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .allowsHitTesting(false)
            .offset(y: smallWatchTimeDrop)

            HStack(alignment: .center, spacing: 0) {
                Button {
                    rosary.exitToMysteryPicker()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(rosaryControlButtonForeground)
                        .frame(width: chromeButtonSize, height: chromeButtonSize)
                }
                .buttonStyle(.plain)
                .background { rosaryGlassCircle(diameter: chromeButtonSize) }
                .accessibilityLabel("Back")

                Spacer(minLength: 0)

                Button {
                    Task { @MainActor in rosary.stopPlayback() }
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: isLargeWatch ? 12 : 11, weight: .semibold))
                        .foregroundStyle(rosaryControlButtonForeground)
                        .frame(width: chromeButtonSize, height: chromeButtonSize)
                }
                .buttonStyle(.plain)
                .background { rosaryGlassCircle(diameter: chromeButtonSize) }
                .accessibilityLabel("Stop")
                .accessibilityIdentifier("TransportStop")
            }
            .padding(.top, -smallWatchTimeDrop)
        }
        .padding(.horizontal, edgeInset)
        .padding(.top, topPad)
        .padding(.bottom, 2)
    }

    private func rosaryGlassCircle(diameter: CGFloat) -> some View {
        Circle()
            .fill(solidChrome ? Color.primary.opacity(0.14) : Color.clear)
            .background(.ultraThinMaterial, in: Circle())
            .overlay {
                Circle()
                    .stroke(
                        solidChrome ? Color.primary.opacity(0.22) : rosaryBrandGoldLight.opacity(0.45),
                        lineWidth: 0.5
                    )
            }
            .frame(width: diameter, height: diameter)
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
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .blur(radius: solidChrome ? 0 : 20)
                        .id(name)

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

    private var textShadowColor: Color {
        solidChrome ? .clear : Color.black.opacity(0.45)
    }

    /// Prayer text only (no rounded card / stroke) so it can run under the floating transport.
    private var rosaryPrayerBody: some View {
        let bodyText = rosary.textForStep(at: rosary.index) ?? ""
        return Text(bodyText)
            .font(DivinityFont.prayerEmphasis(14))
            .foregroundStyle(heroPrimaryText)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .minimumScaleFactor(0.62)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 4)
            .shadow(color: textShadowColor, radius: solidChrome ? 0 : 2, x: 0, y: 1)
    }

    private var rosaryAlbumArtTile: some View {
        Group {
            if let mystery = rosary.selectedMystery {
                let name = MysteryArt.assetName(mystery: mystery, stepIndex: rosary.index, steps: rosary.steps)
                let corner: CGFloat = 12
                Image(name)
                    .renderingMode(.original)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 102, height: 102)
                    .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                    .shadow(color: Color.black.opacity(solidChrome ? 0 : 0.4), radius: 8, x: 0, y: 3)
                    .id(name)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var rosarySessionTitles: some View {
        VStack(alignment: .center, spacing: 4) {
            if let mystery = rosary.selectedMystery {
                Text(mystery.title)
                    .font(.system(size: 11, weight: .medium, design: .default))
                    .foregroundStyle(heroSecondaryText)
                    .textCase(.uppercase)
                    .tracking(0.45)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .shadow(color: textShadowColor, radius: solidChrome ? 0 : 2, x: 0, y: 1)
            }

            if let mysteryTitle = rosary.currentDecadeMysteryShortTitle ?? heroStepTitle {
                Text(mysteryTitle)
                    .font(.system(size: 15, weight: .bold, design: .default))
                    .foregroundStyle(heroPrimaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .lineSpacing(2)
                    .minimumScaleFactor(0.6)
                    .shadow(color: textShadowColor, radius: solidChrome ? 0 : 3, x: 0, y: 1)
            } else if let step = rosary.currentStep {
                let fallback = step.title.trimmingCharacters(in: .whitespacesAndNewlines)
                if !fallback.isEmpty, fallback.caseInsensitiveCompare("Rosary") != .orderedSame {
                    Text(fallback)
                        .font(.system(size: 15, weight: .bold, design: .default))
                        .foregroundStyle(heroPrimaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .lineSpacing(2)
                        .minimumScaleFactor(0.6)
                        .shadow(color: textShadowColor, radius: solidChrome ? 0 : 3, x: 0, y: 1)
                }
            }

            if let label = rosary.hailMaryCounterLabel {
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundStyle(heroSecondaryText)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .shadow(color: textShadowColor, radius: solidChrome ? 0 : 2, x: 0, y: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// Progress + Music-style glass transport (side orbs + ringed play); Stop lives in the top bar.
    private var rosaryFloatingPlayerChrome: some View {
        let nextDisabled = rosary.steps.isEmpty || rosary.index >= rosary.steps.count - 1
        return VStack(spacing: 6) {
            ThinProgressBar(value: rosary.overallProgressFraction, accent: rosaryControlAccentColor, dimmed: !solidChrome, lineHeight: 3)
                .padding(.horizontal, 14)
            HStack(spacing: 18) {
                Spacer(minLength: 0)
                rosaryGlassTransportSideButton(
                    icon: rosary.index == 0 ? "arrow.counterclockwise" : "backward.fill",
                    disabled: false,
                    label: rosary.index == 0 ? "Replay" : "Previous",
                    identifier: "TransportPrevious"
                ) {
                    rosary.previousStep()
                }
                rosaryGlassTransportMainButton()
                rosaryGlassTransportSideButton(
                    icon: "forward.fill",
                    disabled: nextDisabled,
                    label: "Next",
                    identifier: "TransportNext"
                ) {
                    rosary.nextStep()
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
        }
        /// Bottom-aligned in `ZStack`; less top padding + no bottom padding sits transport nearer the watch chin.
        .padding(.top, 5)
        .padding(.bottom, 0)
        .frame(maxWidth: .infinity)
        .background {
            if solidChrome {
                Rectangle()
                    .fill(.regularMaterial)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0),
                        Color.black.opacity(0.35),
                        Color.black.opacity(0.55)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
            }
        }
        /// Nudge toward the chin; paired with extra scroll bottom inset so text stays clear.
        .offset(y: 12)
    }

    private func rosaryGlassTransportSideButton(
        icon: String,
        disabled: Bool,
        label: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(rosaryControlButtonForeground.opacity(disabled ? 0.4 : 0.98))
                .symbolRenderingMode(.monochrome)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .background { rosaryGlassCircle(diameter: 40) }
        .accessibilityLabel(label)
        .accessibilityIdentifier(identifier)
    }

    private func rosaryGlassTransportMainButton() -> some View {
        Button {
            rosary.playPauseTapped()
        } label: {
            Image(systemName: speech.isSpeaking ? "pause.fill" : "play.fill")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(solidChrome ? Color.black.opacity(0.88) : Color.black.opacity(0.82))
                .symbolRenderingMode(.monochrome)
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .background {
            if solidChrome {
                Circle().fill(rosaryBrandGoldDark)
            } else {
                Circle().fill(rosaryControlGoldGradient)
            }
        }
        .overlay {
            Circle()
                .stroke(rosaryBrandGoldLight.opacity(0.95), lineWidth: 2.5)
        }
        .accessibilityLabel(speech.isSpeaking ? "Pause" : "Play")
        .accessibilityIdentifier("TransportPlayPause")
    }

    private struct ThinProgressBar: View {
        let value: Double
        let accent: Color
        var dimmed: Bool = false
        var lineHeight: CGFloat = 5

        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(dimmed ? Color.white.opacity(0.14) : Color.secondary.opacity(0.22))
                    Capsule()
                        .fill(accent)
                        .frame(width: max(4, geo.size.width * min(1, max(0, value))))
                }
                .frame(width: geo.size.width, height: lineHeight, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .frame(height: lineHeight)
        }
    }
}

#Preview {
    NavigationStack {
        RosaryView(rosaryScreenActive: .constant(true))
            .environmentObject(RosarySessionController())
    }
}
