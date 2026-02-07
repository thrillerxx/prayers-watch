import Foundation

#if os(watchOS)
import WatchKit
#endif

enum Haptics {
    static func click() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }

    static func success() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }
}
