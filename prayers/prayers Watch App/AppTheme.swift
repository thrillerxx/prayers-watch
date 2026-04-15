import SwiftUI

/// Named color schemes (accent + scrims). Default: Divinity (app icon gold).
enum AppColorTheme: String, CaseIterable, Identifiable {
    case marian
    case roman
    case lent
    case easter
    case pentecost
    case ordinary
    case night
    /// App icon gold (#F9E29C → #B8860B); matches rosary transport chrome in `RosaryView`.
    case divinity
    /// White accent (papal / liturgical white); listed after Divinity near the bottom of the picker.
    case holyFather
    case highContrast

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .marian: return "Marian"
        case .roman: return "Roman"
        case .lent: return "Lent"
        case .easter: return "Easter"
        case .pentecost: return "Pentecost"
        case .ordinary: return "Ordinary Time"
        case .night: return "Night Prayer"
        case .divinity: return "Divinity"
        case .holyFather: return "Holy Father"
        case .highContrast: return "High Contrast"
        }
    }

    /// Primary accent (progress, prominent buttons).
    func accentColor(reduceTransparency: Bool, increaseContrast: Bool) -> Color {
        switch self {
        case .marian:
            return Color(red: 0.25, green: 0.45, blue: 0.92)
        case .roman:
            return Color(red: 0.65, green: 0.12, blue: 0.15)
        case .lent:
            return Color(red: 0.45, green: 0.32, blue: 0.62)
        case .easter:
            return Color(red: 0.98, green: 0.84, blue: 0.35)
        case .pentecost:
            return Color(red: 0.92, green: 0.28, blue: 0.22)
        case .ordinary:
            return Color(red: 0.35, green: 0.55, blue: 0.48)
        case .night:
            return Color(red: 0.55, green: 0.65, blue: 0.85)
        case .divinity:
            if increaseContrast || reduceTransparency {
                return Color(red: 0.722, green: 0.525, blue: 0.043)
            }
            return Color(red: 0.976, green: 0.886, blue: 0.612)
        case .holyFather:
            return Color.white
        case .highContrast:
            return Color(red: 0.0, green: 0.48, blue: 1.0)
        }
    }

    /// Gradient overlay from top (clearer for titles) to bottom (darker for controls).
    func heroGradientColors(reduceTransparency: Bool, increaseContrast: Bool) -> [Color] {
        if increaseContrast || reduceTransparency {
            return [
                Color.black.opacity(0.55),
                Color.black.opacity(0.82),
                Color.black.opacity(0.92)
            ]
        }
        switch self {
        case .easter:
            return [
                Color.black.opacity(0.25),
                Color.black.opacity(0.55),
                Color.black.opacity(0.78)
            ]
        case .divinity:
            return [
                Color.black.opacity(0.30),
                Color.black.opacity(0.55),
                Color(red: 0.08, green: 0.05, blue: 0.01).opacity(0.88)
            ]
        default:
            return [
                Color.black.opacity(0.35),
                Color.black.opacity(0.62),
                Color.black.opacity(0.85)
            ]
        }
    }

    func dimmedTextOpacity(reduceTransparency: Bool, increaseContrast: Bool) -> Double {
        if increaseContrast { return 0.55 }
        if reduceTransparency { return 0.42 }
        return 0.38
    }
}
