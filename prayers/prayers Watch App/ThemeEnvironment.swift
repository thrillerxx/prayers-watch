import SwiftUI

private struct AppColorThemeKey: EnvironmentKey {
    static let defaultValue: AppColorTheme = .marian
}

extension EnvironmentValues {
    var appColorTheme: AppColorTheme {
        get { self[AppColorThemeKey.self] }
        set { self[AppColorThemeKey.self] = newValue }
    }
}
