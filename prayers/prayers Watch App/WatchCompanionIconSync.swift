import Foundation
import WatchConnectivity

/// Relays the user’s icon choice from the watch to the paired iPhone (alternate icons are applied on iOS only).
final class WatchCompanionIconSync: NSObject, WCSessionDelegate {
    static let shared = WatchCompanionIconSync()

    private let messageKey = "alternateAppIcon"

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    /// Pushes the current selection so the iPhone can call `setAlternateIconName`.
    func notifyPhoneIconChanged(alternateIconAssetName: String) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }

        let token = tokenForPayload(alternateIconAssetName)
        let payload: [String: Any] = [messageKey: token]

        if session.isReachable {
            session.sendMessage(payload, replyHandler: { _ in }, errorHandler: { _ in
                try? session.updateApplicationContext(payload)
            })
        } else {
            try? session.updateApplicationContext(payload)
        }
    }

    private func tokenForPayload(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "default" : trimmed
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else { return }
        let stored = UserDefaults.standard.string(forKey: AppSettings.appAlternateIconKey) ?? ""
        notifyPhoneIconChanged(alternateIconAssetName: stored)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let token = applicationContext[messageKey] as? String else { return }
        let normalized = token.trimmingCharacters(in: .whitespacesAndNewlines)
        let stored = (normalized == "default" || normalized.isEmpty) ? "" : normalized
        UserDefaults.standard.set(stored, forKey: AppSettings.appAlternateIconKey)
    }
}
