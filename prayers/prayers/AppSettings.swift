import Foundation

/// Keys used by the iOS companion app. Kept minimal; the watch app owns most settings.
enum AppSettings {
    /// Must match `AppSettings.appAlternateIconKey` in the Watch target.
    static let appAlternateIconKey = "settings.appearance.alternateAppIcon"
}
