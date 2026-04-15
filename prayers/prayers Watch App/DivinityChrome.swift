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

/// Full-width row used on home, Rosary mystery picker, and Prayer Library (identical geometry).
struct DivinityPickerRowButton: View {

    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

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
        Button(action: action) {
            HStack(alignment: .center, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(accent.opacity(reduceTransparency ? 0.28 : 0.22))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(DivinityPickerRow.iconFont)
                        .foregroundStyle(.white)
                        .symbolRenderingMode(.monochrome)
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(DivinityPickerRow.titleFont)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(DivinityPickerRow.subtitleFont)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(DivinityPickerRow.chevronFont)
                    .foregroundStyle(Color.secondary.opacity(0.85))
                    .frame(width: 14, height: 14)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(stroke, lineWidth: 0.5)
                    }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }
}

struct HomeNavigationTile: View {

    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        DivinityPickerRowButton(icon: icon, title: title, subtitle: subtitle, action: action)
    }
}
