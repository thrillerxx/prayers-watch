import Foundation

/// Selectable alternate icons defined in the iOS asset catalog (`AppIcon*.appiconset`).
/// Empty raw value means the primary `AppIcon`.
enum AlternateAppIconChoice: String, CaseIterable, Identifiable {
    case appDefault = ""
    case radiantCross = "AppIconRadiantCross"
    case triquetra = "AppIconTriquetra"
    case geometricCross = "AppIconGeometricCross"
    case rosaryCross = "AppIconRosaryCross"
    case ichthys = "AppIconIchthys"
    case sacredHeart = "AppIconSacredHeart"
    case openBible = "AppIconOpenBible"
    case dove = "AppIconDove"

    var id: String { rawValue.isEmpty ? "default" : rawValue }

    var title: String {
        switch self {
        case .appDefault: return "Default"
        case .radiantCross: return "Radiant Cross"
        case .triquetra: return "Triquetra"
        case .geometricCross: return "Geometric Cross"
        case .rosaryCross: return "Rosary Cross"
        case .ichthys: return "Ichthys"
        case .sacredHeart: return "Sacred Heart"
        case .openBible: return "Open Bible"
        case .dove: return "Holy Spirit Dove"
        }
    }

    /// Asset name accepted by `UIApplication.setAlternateIconName`, or empty for primary.
    var alternateIconAssetName: String { rawValue }
}
