//
//  SecureYourClipboardApp.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/3/25.
//

import SwiftUI

@main
struct SecureYourClipboardApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
