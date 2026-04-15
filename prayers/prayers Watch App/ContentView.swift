import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var rosary: RosarySessionController

    @AppStorage(AppSettings.colorThemeKey) private var themeRaw: String = AppSettings.defaultColorTheme

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    @State private var path = NavigationPath()
    @State private var rosaryScreenActive = false

    private var theme: AppColorTheme {
        AppColorTheme(rawValue: themeRaw) ?? .marian
    }

    private var accent: Color {
        theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
    }

    private var homeSolidChrome: Bool {
        reduceTransparency || differentiateWithoutColor
    }

    /// Same treatment as rosary now-playing: blurred mystery art + theme hero gradient. Image picked once per cold start.
    private var homeMysteryHeroBackdrop: some View {
        let name = MysteryArt.homeHeroAssetNameForProcess()
        let colors = theme.heroGradientColors(reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
        return ZStack {
            Image(name)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .blur(radius: homeSolidChrome ? 0 : 20)
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

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                homeMysteryHeroBackdrop

                /// Same layout container as `RosaryView.mysteryPicker` (`ScrollView` + `VStack(spacing: 12)` + `.padding(.horizontal, 10)`).
                /// watchOS `List` was shrinking rows / adding insets so tiles never matched mystery rows.
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Spacer(minLength: 0)
                            /// Hero title 20 / tagline 12 to match mystery picker scale; Cinzel + Cormorant branding.
                            VStack(alignment: .center, spacing: 6) {
                                Text("Divinity")
                                    .font(DivinityFont.chrome(20))
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.center)
                                Text("Prayers & Rosary")
                                    .font(DivinityFont.caption(12))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 6)
                        .padding(.bottom, 4)

                        homeTile(.rosary, title: "Rosary", subtitle: "Mysteries", icon: "cross")
                        homeTile(.prayerLibrary, title: "Prayer Library", subtitle: "Browse & listen", icon: "books.vertical.fill")
                        homeTile(.massResponses, title: "Mass Responses", subtitle: "At Mass", icon: "text.book.closed.fill")
                        homeTile(.settings, title: "Settings", subtitle: "Theme & voice", icon: "gearshape.fill")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaPadding(.top, 4)
            .safeAreaPadding(.bottom, 6)
            .navigationDestination(for: NavRoute.self) { route in
                switch route {
                case .rosary:
                    RosaryView(rosaryScreenActive: $rosaryScreenActive)
                case .prayerLibrary:
                    PrayerLibraryView()
                case .massResponses:
                    MassResponsesView()
                case .settings:
                    SettingsView()
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if rosary.isRosaryActive && !rosaryScreenActive {
                    rosaryMiniPlayer
                }
            }
        }
        .tint(accent)
        .environment(\.appColorTheme, theme)
    }

    @ViewBuilder
    private func homeTile(_ route: NavRoute, title: String, subtitle: String, icon: String) -> some View {
        HomeNavigationTile(title: title, subtitle: subtitle, icon: icon) {
            path.append(route)
        }
    }

    private var rosaryMiniPlayer: some View {
        Button {
            path = NavigationPath()
            path.append(NavRoute.rosary)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "cross")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(accent)
                    .symbolRenderingMode(.monochrome)
                    .frame(width: 22, height: 22)

                VStack(alignment: .leading, spacing: 1) {
                    Text(rosary.miniPlayerTitle)
                        .font(DivinityFont.caption(12))
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Text(rosary.miniPlayerSubtitle)
                        .font(DivinityFont.caption(10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 16, height: 16)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DivinityChrome.elevatedSurface(theme: theme, reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(accent.opacity(0.35), lineWidth: 0.5)
                    }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
        .shadow(color: .black.opacity(0.4), radius: 8, y: 3)
        .accessibilityIdentifier("RosaryMiniPlayer")
    }
}

#Preview {
    ContentView()
        .environmentObject(RosarySessionController())
}
