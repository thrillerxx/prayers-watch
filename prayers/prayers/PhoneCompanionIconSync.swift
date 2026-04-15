import UIKit
import WatchConnectivity

/// Receives icon selection from the watch and applies `UIApplication.shared.setAlternateIconName`.
final class PhoneCompanionIconSync: NSObject, UIApplicationDelegate, WCSessionDelegate {
    private static let alternateAppIconPayloadKey = "alternateAppIcon"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        applyStoredAlternateIconIfNeeded()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            applyStoredAlternateIconIfNeeded()
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        applyIconPayload(message)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        applyIconPayload(applicationContext)
    }

    private func applyIconPayload(_ dict: [String: Any]) {
        guard let token = dict[Self.alternateAppIconPayloadKey] as? String else { return }
        let normalized = token.trimmingCharacters(in: .whitespacesAndNewlines)
        let stored = (normalized == "default" || normalized.isEmpty) ? "" : normalized
        UserDefaults.standard.set(stored, forKey: AppSettings.appAlternateIconKey)
        Self.applyIconNameToApplication(stored: stored)
    }

    private static func applyIconNameToApplication(stored: String) {
        let iconName: String? = stored.isEmpty ? nil : stored
        guard UIApplication.shared.supportsAlternateIcons else { return }
        if UIApplication.shared.alternateIconName != iconName {
            UIApplication.shared.setAlternateIconName(iconName) { _ in }
        }
    }

    func applyStoredAlternateIconIfNeeded() {
        let stored = UserDefaults.standard.string(forKey: AppSettings.appAlternateIconKey) ?? ""
        Self.applyIconNameToApplication(stored: stored)
    }

    /// Persists and applies a choice from the iPhone UI (same `UserDefaults` key as the watch).
    static func persistAndApplyLocalSelection(raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let stored = trimmed.isEmpty ? "" : trimmed
        UserDefaults.standard.set(stored, forKey: AppSettings.appAlternateIconKey)
        applyIconNameToApplication(stored: stored)
        pushSelectionToWatch(stored: stored)
    }

    private static func pushSelectionToWatch(stored: String) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        let token = stored.isEmpty ? "default" : stored
        try? session.updateApplicationContext([alternateAppIconPayloadKey: token])
    }
}
