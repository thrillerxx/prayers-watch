import SwiftUI

/// Intentionally a no-op.
///
/// SwiftUI `VideoPlayer` on watchOS is a Now Playing *container*. It ignores
/// `.opacity` / `.frame` and parks media artwork on the chin. That was why the
/// Rosary 102pt cover sat on the transport in every Simulator CFB, including
/// after padding and `.position` changes. Clock hiding uses `_statusBarHidden`
/// on the now-playing session instead.
struct WatchMediaTimeSuppressor: View {
    var body: some View {
        EmptyView()
    }
}
