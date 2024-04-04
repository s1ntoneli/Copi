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
    @StateObject var switchListVM: SwitchListVM = SwitchListVM()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .task {
                    Clipboard.shared.onNewCopy { newItem in
                        interceptCopy(newItem, filters: switchListVM.allEnablesItems)
                    }
                    Clipboard.shared.startListening()
                    MouseEventCatcher.shared.onSelectEventHooks { event in
                        let text = getSelectedText()
                        print("get", text)
                        if let text {
                            PopupWindowController.shared.showWindowAt(event.locationInWindow, text)
                        } else {
                            PopupWindowController.shared.closeWindow()
                        }
                    }
                    MouseEventCatcher.shared.onUnSelectEventHooks { event in
                        PopupWindowController.shared.closeWindow()
                    }
                }
        }
        .windowResizability(.contentSize)

        MenuBarExtra("App", systemImage: "square.stack.3d.down.forward") {
            SwitchListView()
                .environmentObject(switchListVM)
        }
        .menuBarExtraStyle(.window)
        .windowResizability(.contentSize)
    }
}
