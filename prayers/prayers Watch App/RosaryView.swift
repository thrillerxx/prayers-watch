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

    var body: some View {
        Group {
            if let errorText = rosary.errorText {
                Text(errorText)
                    .font(DivinityFont.caption(11))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.horizontal, 10)
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
        List {
            ForEach(RosaryMystery.allCases) { mystery in
                Button {
                    rosary.start(mystery)
                } label: {
                    Label(mystery.title, systemImage: "circle.fill")
                        .font(DivinityFont.title(15))
                }
            }
        }
    }

    private var nowPlayingSession: some View {
        ZStack {
            if let mystery = rosary.selectedMystery {
                mysteryHeroBackground(mystery: mystery)
            }

            VStack(spacing: 0) {
                sessionHeader
                    .padding(.horizontal, 10)
                    .padding(.top, 4)
                    .padding(.bottom, 4)

                lyricsScroll
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                playerChrome
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func mysteryHeroBackground(mystery: RosaryMystery) -> some View {
        let name = MysteryArt.assetName(mystery: mystery, stepIndex: rosary.index, steps: rosary.steps)
        let colors = theme.heroGradientColors(reduceTransparency: reduceTransparency, increaseContrast: increaseContrast)

        return ZStack {
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

    private var sessionHeader: some View {
        VStack(alignment: .center, spacing: 4) {
            if let mystery = rosary.selectedMystery {
                Text(mystery.title)
                    .font(DivinityFont.caption(10))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.4)
            }

            Text(rosary.displayTitle)
                .font(DivinityFont.title(14))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .lineSpacing(2)
                .minimumScaleFactor(0.85)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .center)

            if let label = rosary.hailMaryCounterLabel {
                Text(label)
                    .font(DivinityFont.caption(11))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
        }
        .onLongPressGesture(minimumDuration: 0.55) {
            Task { @MainActor in
                rosary.exitToMysteryPicker()
            }
        }
    }

    private var lyricsScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .center, spacing: 10) {
                    ForEach(Array(rosary.steps.enumerated()), id: \.element.id) { i, step in
                        stepTextBlock(stepIndex: i, step: step)
                            .id(step.id)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
            .onAppear {
                guard rosary.steps.indices.contains(rosary.index) else { return }
                let id = rosary.steps[rosary.index].id
                proxy.scrollTo(id, anchor: .center)
            }
            .onChange(of: rosary.index) { _, newIdx in
                guard rosary.steps.indices.contains(newIdx) else { return }
                let id = rosary.steps[newIdx].id
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo(id, anchor: .center)
                }
            }
        }
    }

    private func stepTextBlock(stepIndex i: Int, step: RosaryStep) -> some View {
        let isActive = i == rosary.index
        let bodyText = rosary.textForStep(at: i) ?? ""
        let dim = theme.dimmedTextOpacity(reduceTransparency: reduceTransparency, increaseContrast: increaseContrast)

        return Text(bodyText)
            .font(isActive ? DivinityFont.prayerEmphasis(14) : DivinityFont.prayer(13))
            .foregroundStyle(isActive ? Color.primary : Color.primary.opacity(dim))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity, alignment: .center)
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
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(chromeBackground)
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
