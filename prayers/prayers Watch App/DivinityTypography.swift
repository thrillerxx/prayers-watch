import SwiftUI
import UIKit

/// Bundled OFL fonts in `Fonts/` (registered via Info.plist) with system-serif fallback if lookup fails.
enum DivinityFont {

    private static func custom(_ name: String, size: CGFloat, fallbackWeight: Font.Weight = .regular) -> Font {
        if UIFont(name: name, size: size) != nil {
            return Font.custom(name, size: size)
        }
        return .system(size: size, weight: fallbackWeight, design: .serif)
    }

    static func chrome(_ size: CGFloat) -> Font {
        custom("Cinzel-SemiBold", size: size, fallbackWeight: .semibold)
    }

    static func title(_ size: CGFloat) -> Font {
        custom("Cinzel-SemiBold", size: size, fallbackWeight: .semibold)
    }

    static func prayer(_ size: CGFloat) -> Font {
        custom("Cormorant-Regular", size: size, fallbackWeight: .regular)
    }

    static func prayerEmphasis(_ size: CGFloat) -> Font {
        custom("Cormorant-Medium", size: size, fallbackWeight: .semibold)
    }

    static func caption(_ size: CGFloat) -> Font {
        custom("Cormorant-Medium", size: size, fallbackWeight: .medium)
    }
}

/// Shared metrics for menu list rows (home, mysteries, prayer library) and matching instructional taglines.
enum DivinityPickerRow {
    static let titleFont = Font.system(size: 15, weight: .semibold, design: .default)
    static let subtitleFont = Font.system(size: 11, weight: .medium, design: .default)
    static let iconFont = Font.system(size: 16, weight: .semibold)
    static let chevronFont = Font.system(size: 11, weight: .semibold)
}

/// Uppercase section labels (mystery picker, prayer library, settings).
enum DivinityMenuSection {
    static let labelFont = Font.system(size: 10, weight: .semibold, design: .default)
}
