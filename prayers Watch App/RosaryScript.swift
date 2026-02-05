import Foundation

struct RosaryStep: Identifiable, Codable {
    let id: String
    let title: String
    let prayerId: String
}

enum RosaryScripts {
    /// Minimal v0 script: opening prayers only. We'll expand to mysteries/decades next.
    static let opening: [RosaryStep] = [
        RosaryStep(id: "soc", title: "Sign of the Cross", prayerId: "sign_of_cross")
    ]
}
