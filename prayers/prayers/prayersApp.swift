//
//  prayersApp.swift
//  prayers
//
//  Created by Car Gonzalez on 2/5/26.
//

import SwiftUI

@main
struct prayersApp: App {
    @UIApplicationDelegateAdaptor(PhoneCompanionIconSync.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
