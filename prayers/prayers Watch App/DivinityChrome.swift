import SwiftUI

enum NavRoute: Hashable {
    case rosary
    case prayerLibrary
    case massResponses
    case settings
}

/// Spotify-inspired dark surfaces and home “tiles” (see `docs/design/mystery-art-ai-prompts.md`).
enum DivinityChrome {

    /// Near-black app canvas (Spotify #121212 family).
    static let canvasBackground = Color(red: 0.07, green: 0.07, blue: 0.08)

    static func elevatedSurface(
        theme: AppColorTheme,
        reduceTransparency: Bool,
        increaseContrast: Bool
    ) -> Color {
        if increaseContrast || reduceTransparency {
            return Color(white: 0.18)
        }
        return Color(white: 0.14)
    }

    static func elevatedSurfaceStroke(
        theme: AppColorTheme,
        accent: Color,
        reduceTransparency: Bool
    ) -> Color {
        if reduceTransparency {
            return Color.white.opacity(0.12)
        }
        return accent.opacity(0.18)
    }
}

struct HomeNavigationTile: View {

    let route: NavRoute
    let title: String
    let subtitle: String
    let icon: String

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

    var body: some View {
        NavigationLink(value: route) {
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(accent.opacity(reduceTransparency ? 0.28 : 0.22))
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(accent)
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DivinityFont.title(14))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    Text(subtitle)
                        .font(DivinityFont.caption(11))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
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
    }
}
